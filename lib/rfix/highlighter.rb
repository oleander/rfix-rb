# frozen_string_literal: true

require "dry/core/constants"
require "dry/initializer"
require "dry/types"
require "rouge"

module Rfix
  class Highlighter < Rouge::Formatters::TerminalTruecolor
    tag "highlighter"

    ESC = "\e"
    NEWLINE = "\n"
    SPACE = " "

    TEXT = Rouge::Token::Tokens::Text

    Error = Class.new(StandardError)

    extend Dry::Initializer
    include Dry::Core::Constants

    module Types
      include Dry::Types()
    end

    option :visible, type: Types::Range
    option :highlight, type: Types::Range
    option :visible_lines, type: Types::Range
    param :theme, default: -> { Rouge::Themes::Gruvbox.new }
    param :lexer, default: -> { Rouge::Lexers::Ruby.new }

    def call(source)
      unless source.is_a?(String)
        raise Error, "Source must be a string"
      end

      unless source.end_with?(NEWLINE)
        raise Error, "Document must end with newline"
      end

      format(lexer.lex(source))
    end

    def stream(tokens, &block)
      prefix_spaces = 2

      indentation = token_lines(tokens).map.with_index(1) do |tokens, lineno|
        next unless visible_lines.include?(lineno)

        text = tokens.map(&:last).join

        next if text.empty?

        text.chars.take_while do |char|
          char.strip.empty?
        end.length
      end.compact.min || 0

      is_h = token_lines(tokens).reduce([0, 1, {}]) do |(position, lineno, lookup), tokens|
        tokens.reduce([position, lineno, lookup]) do |(index, lineno, lookup), (_, value)|
          [index + value.length, lineno, lookup].tap do |_next_index, _, _|
            if highlight.include?(index)
              lookup[lineno] = true
            end
          end
        end.then do |index, lineno, lookup|
          [index.succ, lineno.succ, lookup]
        end
      end.last

      ansi = lambda do |code, terminated|
        lambda do |input|
          [ESC, "[", code.to_s, "m", input, ESC, "[", terminated.to_s, "m"].join
        end
      end

      underline = ansi.call(4, 24)
      boldness = ansi.call(1, 22)
      yellow = ansi.call(33, 22)
      dimness = ansi.call(2, 22)

      underscope = lambda do |output|
        (block << underline).call(output)
      end

      token_lines(tokens).reduce([0, 1]) do |(position, lineno), tokens|
        print_line_number = lambda do
          block.call(SPACE * 2)

          bold = if is_h[lineno]
                   yellow
                 else
                   dimness
                 end

          (block << bold).call(lineno.to_s.ljust(4, SPACE) + SPACE)
        end

        tokens.reduce(position) do |index, (token, value)|
          (index + value.length).tap do
            tokens = []

            if index == position
              value = value.chars.drop(indentation).join

              if visible_lines.include?(lineno)
                print_line_number.call
              end
            end

            if highlight.include?(index)
              if index == position
                head = value.chars.take_while(&:blank?).join
                tail = value.chars.drop_while(&:blank?).join

                super([[TEXT, head]], &block)
                super([[token, tail]], &underscope)
              else
                super([[token, value]], &underscope)
              end
            elsif visible_lines.include?(lineno)
              super([[token, value]], &block)
            end
          end
        end.tap do |new_position|
          if visible_lines.include?(lineno)
            if position == new_position
              print_line_number.call
            end

            block.call(NEWLINE)
          end
        end.then do |position|
          [position.succ, lineno.succ]
        end
      end
    end
  end
end

# frozen_string_literal: true

require "dry/core/constants"
require "dry/initializer"
require "dry/types"
require "rouge"
require "pastel"

module Rfix
  class Highlighter < Rouge::Formatters::TerminalTruecolor
    tag "highlighter"

    TEXT = Rouge::Token::Tokens::Text
    NEWLINE = "\n"
    SPACE = " "

    include Dry::Core::Constants
    extend Dry::Initializer

    module Types
      include Dry::Types()
    end

    param :theme, default: -> { Rouge::Themes::Gruvbox.new }
    param :lexer, default: -> { Rouge::Lexers::Ruby.new }
    option :visible_lines, type: Types::Range
    option :highlight, type: Types::Range
    option :visible, type: Types::Range

    def call(source)
      unless source.is_a?(String)
        raise Error, "Source must be a string"
      end

      unless source.end_with?(NEWLINE)
        return call(source + NEWLINE)
      end

      format(lexer.lex(source))
    end

    def stream(tokens, &block)
      max_with = TTY::Screen.width
      lines = token_lines(tokens)
      pastel = Pastel.new
      prefix_spaces = 2

      indentation = lines.map.with_index(1) do |tokens, lineno|
        next unless visible_lines.include?(lineno)

        text = tokens.map(&:last).join

        next if text.empty?

        text.chars.take_while do |char|
          char.strip.empty?
        end.length
      end.compact.min || 0

      is_h = lines.reduce([0, 1, EMPTY_HASH]) do |(position, lineno, lookup), tokens|
        tokens.reduce([position, lineno, lookup.dup]) do |(index, lineno, lookup), (_, value)|
          [index + value.length, lineno, lookup].tap do
            if highlight.include?(index)
              lookup[lineno] = true
            end
          end
        end.then do |index, lineno, lookup|
          [index.succ, lineno.succ, lookup]
        end
      end.last

      lines.reduce([0, 1]) do |(position, lineno), tokens|
        print_line_number = lambda do
          style = is_h[lineno] ? pastel.yellow.detach : pastel.dim.detach
          block.call((SPACE * 2) + style.call(lineno.to_s.ljust(4, SPACE)) + SPACE)
        end

        tokens.reduce(position) do |index, (token, value)|
          (index + value.length).tap do
            if index == position
              value = value.chars.drop(indentation).join

              if visible_lines.include?(lineno)
                print_line_number.call
              end
            end

            if highlight.include?(index) && visible_lines.include?(lineno)
              if index == position
                head = value.chars.take_while(&:blank?).join
                tail = value.chars.drop_while(&:blank?).join

                super([[TEXT, head]], &block)
                super([[token, tail]], &block)
              else
                super([[token, value]], &block)
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

            super([[TEXT, NEWLINE]], &block)
          end
        end.then do |position|
          [position.succ, lineno.succ]
        end
      end
    end
  end
end

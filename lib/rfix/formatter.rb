# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "rubocop/formatter/simple_text_formatter"
require "rubocop/cop/offense"
require "dry/core/constants"
require "dry/initializer"
require "tty/screen"
require "tty/prompt"
require "tty/box"

RuboCop::Cop::Offense.prepend(Rfix::Extension::Offense)

module Rfix
  class Formatter < RuboCop::Formatter::SimpleTextFormatter
    attr_reader :indicator

    include Dry::Core::Constants
    extend Dry::Initializer
    include Log

    option :indicator, default: -> { Indicator.new }
    option :reported_offenses
    option :options
    option :output

    PROMPT = TTY::Prompt.new(symbols: { marker: ">" })
    SPACE = " "

    delegate :say, to: :PROMPT

    class NullRepository
      include Singleton

      def include_file?(*)
        true
      end
    end

    def initialize(output, options = EMPTY_HASH)
      super(output: output, options: options, reported_offenses: EMPTY_ARRAY.dup)
    end

    def started(files)
      # indicator.start("{{italic:rfix}} is linting {{bold:#{files.count}}} files, hold on ...")
    end

    # @files [Array<File>]
    def finished(files)
      # @indicator.stop
      mark_command_line
      report_summary(files)
    end

    # @file [File]
    # @offenses [Array<Offence>]
    def file_finished(*, offenses)
      @reported_offenses += offenses

      # @indicator.stop if offenses?

      length = offenses.length - 1
      offenses.each_with_index do |offense, _index|
        framed(offense) do
          report_line_with_highlight(offense)
        end

        puts
      end
    end

    private

    using(Module.new do
      refine String do
        def surround(value)
          value + self + value
        end
      end
    end)

    def framed(offense, &block)
      puts TTY::Box.frame({
        width: TTY::Screen.width,
        padding: [1, 1, 0, 1],
        title: {
          top_left: "#{offense.icon} #{offense.msg}".surround(SPACE),
          bottom_left: offense.clickable_severity&.surround(SPACE),
          bottom_right: offense.clickable_path&.surround(SPACE)
        }.compact
      }, &block)
    end

    def report_summary(files)
      super(*stats.insert(0, files.count).take(arity))
    end

    def arity
      method(:report_summary).super_method.arity
    end

    def mark_command_line
      # "#{ESC}]1337;SetMark\a"
      "" # TODO: Activate
    end

    def report(msg, format: true)
      msg
    end

    def newline(amount = 1)
      report("\n" * amount)
    end

    def report_line_with_highlight(offense)
      location = offense.location

      unless location.respond_to?(:source_buffer)
        return "Source not found"
      end

      buffer = location.source_buffer

      source = buffer.source
      line = location.line
      last_line = buffer.last_line
      surrounding_lines = 2

      min_line = [line - surrounding_lines * 2, 1].max
      max_line = [line + surrounding_lines * 2, last_line].min

      begin_index = buffer.line_range(min_line).begin_pos
      end_index = buffer.line_range(max_line).end_pos

      visible = begin_index...end_index
      highlight = location.to_range

      highlighter = Highlighter.new(
        visible_lines: (min_line..max_line),
        highlight: highlight,
        visible: visible
      )

      (method(:report) << highlighter).call(source)
    end

    def corrected
      reported_offenses.select(&:corrected?)
    end

    def correctable
      reported_offenses.select(&:correctable?)
    end

    def stats
      [reported_offenses.count, corrected.count, correctable.count]
    end

    def offenses?
      reported_offenses.any?
    end

    def repository
      NullRepository.instance
    end
  end
end

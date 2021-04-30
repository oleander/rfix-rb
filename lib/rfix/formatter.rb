# frozen_string_literal: true

require "rubocop/formatter/simple_text_formatter"
require "rubocop/cop/offense"
require "dry/core/constants"
require "dry/initializer"
require "singleton"
require "tty/box"
require "tty/prompt"

RuboCop::Cop::Offense.prepend(Rfix::Extension::Offense)

module Rfix
  class Formatter < RuboCop::Formatter::SimpleTextFormatter
    ESC = "\e"
    attr_reader :indicator

    include Dry::Core::Constants
    extend Dry::Initializer
    include Log

    option :indicator, default: -> { Indicator.new }
    option :reported_offenses
    option :options
    option :output

    PROMPT = TTY::Prompt.new(symbols: { marker: ">" })

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

      offenses.each do |offense|
        framed(offense) do
          report_line_with_highlight(offense)
        end
      end
    end

    private

    def framed(offense, &block)
      title = "#{offense.icon} #{offense.msg}"
      foot = "#{offense.clickable_severity} » #{offense.clickable_path}"
      say TTY::Box.frame(title: { top_left: title, bottom_right: foot }, &block)
    end

    def report_summary(files)
      files.select do |file|
        repository.include_file?(file)
      end.then do |cleaned_files|
        super(*stats.insert(0, cleaned_files.count).take(arity))
      end
    end

    def arity
      method(:report_summary).super_method.arity
    end

    def mark_command_line
      "#{ESC}]1337;SetMark\a"
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

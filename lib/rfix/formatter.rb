# frozen_string_literal: true

require "active_support/core_ext/module/concerning"
require "active_support/core_ext/module/delegation"
require "rubocop/formatter/simple_text_formatter"
require "rubocop/cop/offense"
require "dry/core/constants"
require "dry/initializer"
require "tty/progressbar"
require "tty/screen"
require "tty/prompt"
require "tty/table"
require "tty/box"

module Rfix
  class Formatter < RuboCop::Formatter::SimpleTextFormatter
    include Dry::Core::Constants
    extend Dry::Initializer
    include Log

    NoSuchFileError = Class.new(Error)

    using(Module.new do
      refine String do
        def surround(value)
          value + self + value
        end
      end

      refine RuboCop::Cop::Offense.const_get(:PseudoSourceRange) do
        def source_buffer
          raise NoSuchFileError
        end
      end
    end)


    option :reported_offenses, default: -> { EMPTY_ARRAY.dup }
    option :options, default: -> { EMPTY_HASH.dup }
    option :progress
    option :options
    option :output

    SURROUNDING_LINES = 2
    NEWLINE = "\n"
    SPACE = " "
    PADDING = 1

    def initialize(output, options = EMPTY_HASH)
      TTY::ProgressBar.new("[:bar]", output: output).then do |bar|
        super(output, output: output, options: options, progress: bar)
      end
    end

    def started(files)
      progress.configure do |config|
        config.bar_format = :block
        config.total = files.count
        config.clear_head = false
        config.clear = false
        config.width = width
      end
    end


    # @file [File]
    # @offenses [Array<Offence>]
    def file_finished(*, offenses)
      @reported_offenses += offenses

      progress.advance

      offenses.each_with_index do |offense, index|
        progress.log(NEWLINE) unless index.zero?

        framed(offense) do
          report_line_with_highlight(offense)
        end
      rescue NoSuchFileError
        # NOP
      end
    end

    def file_started(file, options)
      progress.log "FILE: #{file}"
    end

    # @files [Array<File>]
    def finished(files)
      progress.finish
      mark_command_line
      report_summary(files)
    end

    private

    def width
      TTY::Screen.width
    end

    def framed(offense, &block)
      puts block.call
      progress.log TTY::Box.frame({
        width: width,
        padding: [PADDING, PADDING, 0, PADDING],
        title: {
          top_left: "#{offense.icon} #{offense.msg}".surround(SPACE),
          bottom_left: offense.clickable_severity&.surround(SPACE),
          bottom_right: offense.clickable_path&.surround(SPACE)
        }
      }, &block)
    end

    def report_summary(files)
      super(*stats.insert(0, files.count).take(arity))
    end

    def arity
      method(:report_summary).super_method.arity
    end

    def mark_command_line
      # progress.log "\e]1337;SetMark\a"
    end

    def report_line_with_highlight(offense)
      location = offense.location

      buffer = location.source_buffer

      source = buffer.source
      line = location.line
      last_line = buffer.last_line

      min_line = [line - SURROUNDING_LINES * 2, 1].max
      max_line = [line + SURROUNDING_LINES * 2, last_line].min

      begin_index = buffer.line_range(min_line).begin_pos
      end_index = buffer.line_range(max_line).end_pos

      visible = begin_index...end_index
      highlight = location.to_range

      highlighter = Highlighter.new(
        visible_lines: (min_line..max_line),
        highlight: highlight,
        visible: visible
      )

      progress.log("Okokokokokok")
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

    def debug(files, header)
      return if files.none? || !debug?

      progress.log TTY::Table.new(header, files.map(&:to_table).to_a, {
        padding: PADDING,
        width: width
      }).render(:unicode)
    end
  end
end

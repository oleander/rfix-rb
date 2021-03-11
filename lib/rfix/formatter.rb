# frozen_string_literal: true

require "rubocop"
require "rouge"
require "rainbow"
require "shellwords"

module Rfix
  class Formatter < RuboCop::Formatter::SimpleTextFormatter
    include Rfix::Log

    def started(files)
      theme      = Rouge::Themes::Gruvbox.new
      @formatter = Rouge::Formatters::TerminalTruecolor.new(theme)
      @current   = 0
      @total     = files.count
      @files     = {}
      @lexer     = Rouge::Lexers::Ruby.new
      @pg        = CLI::UI::Progress.new
      @all_files = files
    end

    def truncate(path)
      path.sub(::File.join(Dir.getwd, "/"), "")
    end

    def render_files(files)
      return unless Rfix.test?

      files.each do |file|
        offenses = @files.fetch(file)
        corrected = offenses.select(&:corrected?)

        if offenses.empty?
          say truncate(file)
        elsif offenses.count == corrected.count
          say truncate(file)
        else
          say_error truncate(file)
        end
      end
    end

    def finished(files)
      render_files(files)

      files.each do |file|
        render_file(file, @files.fetch(file))
      end

      offenses = @files.values.flatten
      corrected = offenses.select(&:corrected?)
      out("\n") unless @total.zero?
      report_summary(files.size, offenses.count, corrected.count)
    end

    def render_file(file, offenses)
      return if offenses.empty?

      offenses.each do |offense|
        out("\n\n")
        CLI::UI::Frame.open("#{offense.icon} #{offense.msg}", color: :reset)
        report_line(file, offense, offense.location, offense.highlighted_area)
        CLI::UI::Frame.close("#{offense.clickable_severity} » #{offense.clickable_path}", color: :reset)
      end
    end

    def mark
      CLI::UI::ANSI::ESC + "]1337;SetMark" + "\x07"
    end

    def file_finished(file, offenses)
      out("\n") if @current == 0.0
      @current += 1.0
      unless Rfix.test?
        @pg.tick(set_percent: (@current / @total))
      end
      @files[file] = offenses
    end

    def out(msg, format: true)
      CLI::UI.puts(msg, to: output, format: format)
    end

    def fmt(msg)
      CLI::UI.fmt(msg, enable_color: true)
    end

    def dim(value)
      Rainbow(value).lightgray
    end

    def highlighted_source_line(offense)
      source_before_highlight(offense) +
        hightlight_source_tag(offense) +
        source_after_highlight(offense)
     end

    def hightlight_source_tag(offense)
      offense.highlighted_area.source
   end

    def source_before_highlight(offense)
      source_line = offense.location.source_line
      source_line[0...offense.highlighted_area.begin_pos]
    end

    def source_after_highlight(offense)
      source_line = offense.location.source_line
      source_line[offense.highlighted_area.end_pos..-1]
    end

    def report_line(_file, offense, _location, highlighted_area)
      extra = "  "
      src = highlighted_source_line(offense).lines.map { |line| extra + line }.join("\n")
      indent = Indentation.new(src, extra_indentation: 2)
      src = indent.call
      lines = @formatter.format(@lexer.lex(src)).gsub('\\e', CLI::UI::ANSI::ESC).lines.map(&:chomp)
      out("\n\n")
      out(lines.join("\n"), format: false)
      b_pos = highlighted_area.begin_pos + extra.length * 2 - indent.min_indentation
      e_pos = highlighted_area.end_pos + extra.length * 2 - indent.min_indentation
      size =  e_pos - b_pos
      out((" " * b_pos) + Rainbow((" " * [size, 0].max)).underline.bold)
      out("\n\n")
    end
  end
end

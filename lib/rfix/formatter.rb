# frozen_string_literal: true

require "rubocop"
require "rouge"
require "rainbow"
require "shellwords"

module Rfix
  class Formatter < RuboCop::Formatter::SimpleTextFormatter
    def started(files)
      theme = Rouge::Themes::Gruvbox.new
      @formatter = Rouge::Formatters::TerminalTruecolor.new(theme)
      @lexer = Rouge::Lexers::Ruby.new
      out "{{v}} Loading {{yellow:#{files.count}}} files"
      out("\n")
      @pg = CLI::UI::Progress.new
      @total = files.count
      @current = 0
      @files = {}
    end

    def finished(files)
      files.each do |file|
        render_file(file, @files.fetch(file))
      end

      offenses = @files.values.flatten
      corrected = offenses.select(&:corrected?)
      out("\n")
      report_summary(files.size, offenses.count, corrected.count)
    end

    def to_clickable(url, title)
      esc = CLI::UI::ANSI::ESC
      cmd = esc + "]8;;"
      slash = "\x07"
      cmd + "#{escape(url)}#{slash}#{escape(title)}" + cmd + slash
    end

    def to_path(path, title)
      to_clickable("file://#{path}", title)
    end

    def to_url(url, title)
      to_clickable(url, title)
    end

    def escape(str)
      Shellwords.escape(str)
    end

    def render_file(file, offenses)
      return if offenses.empty?

      path = Rfix.to_relative(path: file)
      url = to_url(file, path)
      offenses.each do |offense|
        out("\n\n")
        clickable_path = "{{italic:#{path}:#{offense.where}}}"
        clickable_code = to_url("https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/#{offense.code}", offense.code)
        CLI::UI::Frame.open("#{offense.icon} #{offense.msg}", color: :reset)
        report_line(file, offense, offense.location, offense.highlighted_area)
        CLI::UI::Frame.close("#{clickable_path} » {{italic:#{clickable_code}}}", color: :reset)
      end
    end

    def mark
      CLI::UI::ANSI::ESC + "]1337;SetMark" + "\x07"
    end

    def file_finished(file, offenses)
      @current += 1.0
      @pg.tick(set_percent: (@current / @total))
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
      lines = @formatter.format(@lexer.lex(src)).gsub('\\e', CLI::UI::ANSI::ESC).lines.map(&:chomp)
      out("\n\n")
      out(lines.join("\n"), format: false)
      b_pos = highlighted_area.begin_pos + extra.length
      e_pos = highlighted_area.end_pos + extra.length
      size =  e_pos - b_pos
      out((" " * b_pos) + Rainbow((" " * size)).underline.bold)
      out("\n\n")
    end
  end
end

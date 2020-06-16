# frozen_string_literal: true

require "rubocop"
require "rouge"
require "rainbow"

module Rfix
  class Formatter < RuboCop::Formatter::SimpleTextFormatter
    def started(files)
      theme = Rouge::Themes::Gruvbox.new
      @formatter = Rouge::Formatters::TerminalTruecolor.new(theme)
      @lexer = Rouge::Lexers::Ruby.new
      out "#{mark}{{*}} Loading {{yellow:#{files.count}}} files"
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

      report_summary(files.size, offenses.count, corrected.count)
    end

    def to_url(url, title)
      esc = CLI::UI::ANSI::ESC
      cmd = esc + "]8;;"
      slash = "\x07"
      cmd + "atom://#{url}#{slash}#{title}" + cmd + slash
    end

    def render_file(file, offenses)
      return if offenses.empty?

      path = Rfix.to_relative(path: file)

      # if offenses.count == 1
      #   return render_one_offens(path, file, offenses.first)
      # end

      url = to_url(file, path)

      offenses.each do |offense|
        out("\n\n")
        # unless offenses.last == offense
        url = to_url("#{file}:#{offense.where}", dim("#{path}:#{offense.where}"))
        CLI::UI::Frame.open("#{offense.icon} #{offense.msg}", color: :reset)
        report_line(file, offense, offense.location, offense.highlighted_area)
        CLI::UI::Frame.close("#{url} » #{offense.code}", color: :reset)
        # end
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

      # src = Rfix.source(file).buffer.source
      # src = highlighted_area.source
      # pp highlighted_area or rescue nil
      # pp location or rescue nil
      # pp offense
      # start_col = location.begin_pos
      # end_col = location.end_pos
      # col_range = (start_col...end_col)
      # # src = File.read(file)
      #
      # pre = '    '
      # x_pre = '⮑   '
      #
      # _, tokens = @lexer.lex(src).reduce([0, []]) do |(column, acc), (token, value)|
      #   length = value.length
      #   if col_range.include?(column)
      #     value = Rainbow(value).inverse.italic
      #   end
      #   [column + length, acc + [[token, value]]]
      # end
      #
      lines = @formatter.format(@lexer.lex(src)).gsub('\\e', CLI::UI::ANSI::ESC).lines.map(&:chomp)
      #
      # line = offense.last_line - 1
      # a = (lines.slice([line - 2, -1].max, 2) || []).map { |l| pre + l }
      # b = [x_pre + lines[line]]
      # c = (lines.slice(line + 1, 2) || []).map { |l| pre + l }
      # d = (a + b + c).join("\n")

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

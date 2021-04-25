require "rainbow"

module Rfix
  module Extension
    module Offense
      def where
        "#{line}:#{real_column}"
      end

      def info
        message.split(": ", 2).last.delete("\n")
      end

      def msg
        CLI::UI.resolve_text("{{italic:#{info}}}", truncate_to: CLI::UI::Terminal.width - 10)
      end

      def code
        message.split(": ", 2).first
      end

      def star
        Rainbow("⭑")
      end

      def cross
        Rainbow("✗").red
      end

      def check
        Rainbow("✓").green
      end

      def circle
        Rainbow("⍟")
      end

      def relative_path
        # TODO: Fix this, do not use Dir.getwd, use git root
        location.source_buffer.name.sub(::File.join(Dir.getwd, "/"), "")
      end

      def clickable_path
        "{{italic:#{relative_path}:#{where}}}"
      end

      def clickable_plain_severity
        to_url("https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/#{code}", code)
      end

      def clickable_severity
        "{{#{severity.code}}} {{italic:#{clickable_plain_severity}}}"
      end

      def icon
        return check.green if corrected?
        return star.yellow if correctable?

        cross.red
      end

      def to_clickable(url, title)
        esc = CLI::UI::ANSI::ESC
        cmd = "#{esc}]8;;"
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
    end
  end
end

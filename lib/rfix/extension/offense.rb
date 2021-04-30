# frozen_string_literal: true

require "shellwords"
require "rainbow"
require "pry"

module Rfix
  module Extension
    module Offense
      ESC = "\e".freeze
      SLASH = "\x07".freeze

      STAR = Rainbow("⭑").yellow
      CROSS = Rainbow("✗").red
      CHECK = Rainbow("✓").green
      CIRCLE = Rainbow("⍟").blue

      include Dry::Core::Constants

      def where
        "#{line}:#{real_column}"
      end

      def info
        message.split(": ", 2).last.delete("\n")
      end

      def msg
        Rainbow(info).italic
      end

      def code
        message.split(": ", 2).first
      end

      def relative_path
        return EMPTY_STRING unless location.respond_to?(:source_buffer)

        location.source_buffer.name.sub(::File.join(Dir.getwd, "/"), EMPTY_STRING)
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
        {
          uncorrected: CIRCLE,
          unsupported: CROSS, # TODO: Use a better one
          correctable: STAR,
          corrected: CHECK
        }.fetch(status)
      end

      def to_clickable(url, title)
        cmd = "#{ESC}]8;;"
        cmd + "#{escape(url)}#{SLASH}#{escape(title)}" + cmd + SLASH
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

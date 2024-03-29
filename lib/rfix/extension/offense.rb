# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
require "dry/core/constants"
require "shellwords"
require "pathname"
require "tty-link"
require "rainbow"
require "rubocop"
require "rubocop/cop/offense"

module RuboCop
  module Cop
    class Offense
      # concerning :Features do
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

      def relative_path(root_path)
        return EMPTY_STRING unless location.respond_to?(:source_buffer)

        Pathname(location.source_buffer.name).relative_path_from(root_path)
      end

      def clickable_path(root_path)
        Rainbow("#{relative_path(root_path)}:#{where}").italic
      end

      def href
        cop_name.split("/", 2).then do |department, cop|
          return nil if [cop, department].any?(&:nil?)

          { type: department.parameterize, cop: cop.parameterize }
        end.then do |options|
          "https://docs.rubocop.org/rubocop/cops_%<type>s.html#%<type>s%<cop>s" % options
        end
      end

      def clickable_plain_severity
        TTY::Link.link_to(cop_name, href)
      end

      def clickable_severity
        clickable_plain_severity && Rainbow(clickable_plain_severity).italic
      end

      def icon
        {
          uncorrected: CIRCLE,
          unsupported: CROSS,
          correctable: STAR,
          corrected: CHECK
        }.fetch(status)
      end

      def escape(str)
        Shellwords.escape(str)
      end
      # end
    end
  end
end

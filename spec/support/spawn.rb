# frozen_string_literal: true

require "rfix/log"
require "rouge"
require "rugged"

module Aruba
  module Processes
    class SpawnProcess
      include Rfix::Log

      def repo
        @repo ||= Rugged::Repository.discover(working_directory)
      end

      def tree
        repo.head.target.tree
      end

      def files
        div("All files check-in") do
          tree.each_blob do |blob|
            say blob.fetch(:name)
          end
        end
      end

      def status
        div("Git Status") do
          repo.status do |path, status|
            say "{{yellow:#{status}}} #{path}"
          end
        end
      end

      def output
        @output ||= Stdout::Output.new(stdout)
      rescue JSON::ParserError => e
        dump!(include_output: false, error: e)
        raise e.to_s
      end

      def have_offenses_for?(file)
        output.have_offenses_for?(file)
      end

      def root_path
        File.join(File.expand_path(File.join(__dir__, "../..")), "/")
      end

      def absolute_to_relative(str)
        str
        # str.gsub(root_path, "<root>").chomp
      end

      def failed?
        exit_status != 0
      end

      def colorize(path:)
        data = File.read(path)
        return data if File.extname(path) != ".rb"

        theme     = Rouge::Themes::Gruvbox.new
        formatter = Rouge::Formatters::TerminalTruecolor.new(theme)
        lexer     = Rouge::Lexers::Ruby.new
        formatter.format(lexer.lex(data)).lines.each_with_index.map do |index, line|
          [line + 1, index.chomp].join(": ")
        end.join("\n")
      end

      # def colorize_json(data)
      #   data = JSON.pretty_generate(JSON.parse(data))
      #   theme     = Rouge::Themes::Gruvbox.new
      #   formatter = Rouge::Formatters::TerminalTruecolor.new(theme)
      #   lexer     = Rouge::Lexers::JSON.new
      #   formatter.format(lexer.lex(data))
      # rescue JSON::ParserError => e
      #   data
      # end

      def stdout_json?
        return false if stdout.chomp.empty?

        !!JSON.parse(stdout)
      rescue JSON::ParserError
        false
      end

      def dump!(include_output: true, **)
        # return if @dump

        box("PWD", color: :reset) do
          prt absolute_to_relative(Dir.pwd)
          prt "\n\n"

          div("CMD") do
            prt command_string.to_a.map(&method(:absolute_to_relative)).join(" ")
          end

          @output&.files&.each_with_index do |path, index|
            div("Loaded {{italic:{{yellow:#{path}}}}} (#{index + 1})") do
              prt colorize(path: path)
            end
          end

          if include_output
            div("DUMP", color: :reset) do
              prt "\n"
              output.dump!
            end
          end

          status
          files

          unless stdout_json?
            div("STDOUT", color: :reset) do
              prt stdout.chomp
            end
          end

          unless stderr.strip.empty?
            div("STDERR", color: :red) do
              prt stderr # absolute_to_relative(stderr)
            end
          end
        end

        @dump = true
      end

      def has_corrected?(file)
        output.has_corrected?(file)
      end

      def has_linted?(file)
        output.has_linted?(file)
      end

      def offenses(*args, &block)
        output.offenses(*args, &block)
      end

      def fixed_lines_str
        output.fixed_lines_str
      end

      def linted_lines_str
        output.linted_lines_str
      end
    end
  end
end

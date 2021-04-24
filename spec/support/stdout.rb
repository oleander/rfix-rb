require "jsonpath"
require "rouge"

module Stdout
  class Base
    attr_reader :json

    include Rfix::Log

    def select(path)
      JsonPath.new(path)[json]
    end
  end

  class Output < Base
    def initialize(stdout)
      super()
      @json = JSON.parse(stdout)
    end

    def dump!
      data = JSON.pretty_generate(@json)
      theme = Rouge::Themes::Gruvbox.new
      formatter = Rouge::Formatters::TerminalTruecolor.new(theme)
      lexer     = Rouge::Lexers::JSON.new
      say_plain formatter.format(lexer.lex(data))
    end

    def have_offenses_for?(file)
      !!load_offenses(file)&.any?
    end

    def offenses(file, &block)
      if ox = load_offenses(file)
        block.call(Offense.new(ox))
      end
    end

    def files
      select("files[:].path").to_a
    end

    def has_corrected?(file)
      fixed_files.any? do |other|
        file.to_path == other
      end
    end

    def has_linted?(file)
      linted_files.any? do |other|
        file.to_path == other
      end
    end

    def fixed_files
      @json.fetch("files").select do |file|
        file.fetch("offenses").any? do |offense|
          offense.fetch("corrected")
        end
      end.map { |file| file.fetch("path") }
    end

    def linted_files
      @json.fetch("files").select do |file|
        file.fetch("offenses").all? do |offense|
          !offense.fetch("corrected")
        end
      end.map { |file| file.fetch("path") }
    end

    def linted_lines_str
      files = linted_files.to_a
      if files.empty?
        if fixed_files.any?
          return fixed_lines_str
        end

        return "{{error:didn't lint anything}}"
      end
      intro = "only #{files.join(', ')}"
      if fixed_files.any?
        intro << " linted and #{fixed_lines_str} {{red:fixed}}"
      else
        intro << " were"
      end

      return intro
    end

    def fixed_lines_str
      return "{{warning:nothing}} was" unless fixed_files.any?

      "{{warning:only}} #{files.to_a.join(', ')} were"
    end

    private

    def load_offenses(file)
      @json.fetch("files").select do |other|
        other.fetch("path") == file.to_path
      end.map { |inner_file| inner_file.fetch("offenses") }.first
    end
  end

  class Offense < Base
    def initialize(obj)
      super()
      @obj = obj
    end

    def corrected?(on:)
      @obj.select do |offense|
        offense.fetch("location").fetch("line") == on
      end.any? do |offense|
        offense.fetch("corrected")
      end
    end

    def linted?(on:)
      @obj.select do |offense|
        offense.fetch("location").fetch("line") == on
      end.all? do |offense|
        !offense.fetch("corrected")
      end
    end

    def linted_lines
      @obj.reject do |offense|
        offense.fetch("corrected")
      end.map do |offense|
        offense.fetch("location").fetch("line")
      end
    end

    def fixed_lines
      @obj.select do |offense|
        offense.fetch("corrected")
      end.map do |offense|
        offense.fetch("location").fetch("line")
      end
    end
  end
end

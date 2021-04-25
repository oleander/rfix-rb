require "dry/core/memoizable"
require "strings-ansi"

module Rfix
  class Indentation
    include Dry::Core::Memoizable
    SPACE = " ".freeze

    attr_reader :extra_indentation, :input

    def initialize(input, extra_indentation: 2)
      @input = input
      @extra_indentation = extra_indentation
    end

    def stripped
      lines.drop_while do |line|
        Strings::ANSI.sanitize(line).blank?
      end.take_while do |line|
        Strings::ANSI.sanitize(line).present?
      end.map do |line|
        line.gsub(/^\s{#{min_indentation}}/, "")
      end.map do |line|
        [SPACE * extra_indentation, line].join
      end.join
    end

    alias call stripped

    private

    def min_indentation
      lines.map do |line|
        line.match(/^\s*/)[0].length
      end.min || 0
    end

    def lines
      input.lines
    end

    memoize :min_indentation, :lines
  end
end

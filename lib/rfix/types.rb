# frozen_string_literal: true

require "dry/types"

module Rfix
  module Types
    include Dry::Types()

    Rugged = Instance(Rugged::Repository)

    Dry::Types.define_builder(:superset) do |type, *array|
      Constructor(type) do |value, &error|
        set = Types::Symbol.constrained(included_in: array)

        type.call(value, &error).map do |el|
          set.call(el, &error)
        end
      end
    end

    def self.Statuses(*symbols)
      set = symbols.map do |symbol|
        Types.Value(symbol)
      end.reduce(:|)

      Types.Array(Types::Symbol).constructor do |value, type, &error|
        type.call(value, &error).tap do |value|
        end.map do |symbol|
          set.call(symbol, &error)
        end
      end
    end
  end
end

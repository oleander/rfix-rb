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
  end
end

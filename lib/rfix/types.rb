# frozen_string_literal: true

require "dry/types"
require "dry/logic"

module Rfix
  module Types
    include Dry::Types()

    Rugged = Instance(::Rugged::Repository)

    Dry::Types.define_builder(:not) do |type, fallback|
      Dry::Types::Constrained.new(fallback, rule: Dry::Logic::Operations::Negation.new(type.rule))
    end

    module Status
      include Dry::Types()

      List = Array(Symbol)

      Deleted = List.constrained(includes: :worktree_deleted)
      Ignored = List.constrained(includes: :ignored) << Deleted.not(List)

      NewWorkTree = List.constrained(includes: :worktree_new)
      NewIndex = List.constrained(includes: :index_new)
      Untracked = (NewWorkTree | NewIndex) << Ignored.not(List)

      Tracked = Untracked.not(List)
    end

    def self.Statuses(*symbols)
      set = symbols.map do |symbol|
        Types.Value(symbol)
      end.reduce(:|)

      Types.Array(Types::Symbol).constructor do |value, type, &error|
        type.call(value, &error).map do |symbol|
          set.call(symbol, &error)
        end
      end
    end
  end
end

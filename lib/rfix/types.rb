# frozen_string_literal: true

require "dry/types"
require "dry/logic"

module Rfix
  module Types
    include Dry::Types()
    include Dry::Logic

    Rugged = Instance(::Rugged::Repository)

    Dry::Types.define_builder(:not) do |type|
      Dry::Types::Constrained.new(type.lax, rule: Operations::Negation.new(type.rule))
    end

    Dry::Types.define_builder(:and) do |left, right|
      Dry::Types::Constrained.new(left.lax, rule: Operations::And.new(left.rule, right.rule))
    end

    Dry::Types.define_builder(:or) do |left, right|
      Dry::Types::Constrained.new(left.lax, rule: Operations::Or.new(left.rule, right.rule))
    end

    module Status
      include Dry::Types()

      List = Array(Symbol)

      Deleted = List.constrained(includes: :worktree_deleted)
      Ignored = List.constrained(includes: :ignored).and(Deleted.not)

      module Staged
        Tree = List.constrained(includes: :worktree_new)
        Index = List.constrained(includes: :index_new)
      end

      Untracked = Staged::Tree.or(Staged::Index).and(Ignored.not)
      Tracked = Untracked.not

      puts Tracked.rule.to_s
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

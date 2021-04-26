# frozen_string_literal: true

require "dry/types"
require "dry/logic"

module Rfix
  module Types
    include Dry::Types()
    include Dry::Logic

    Rugged = Instance(::Rugged::Repository)
    Constrained = Dry::Types::Constrained

    Dry::Types.define_builder(:not) do |type|
      Constrained.new(type.lax, rule: Operations::Negation.new(type.rule))
    end

    Dry::Types.define_builder(:and) do |left, right|
      Constrained.new(left.lax << right.lax, rule: left.rule & right.rule)
    end

    Dry::Types.define_builder(:or) do |left, right|
      Constrained.new(left.lax << right.lax, rule: left.rule | right.rule)
    end

    module Status
      include Dry::Types()

      List = Array(Symbol)

      WorkTreeDeleted = List.constrained(includes: :worktree_deleted)
      DeletedOther = List.constrained(includes: :deleted)
      Deleted = WorkTreeDeleted.or(DeletedOther)

      module IgnoredType
        Ignored = List.constrained(includes: :ignored)
        Unmodified = List.constrained(includes: :unmodified)
      end

      Ignored = IgnoredType::Ignored.or(IgnoredType::Unmodified).and(Deleted.not)

      module Staged
        Tree = List.constrained(includes: :worktree_new)
        Index = List.constrained(includes: :index_new)
      end

      Untracked = Staged::Tree.or(Staged::Index).and(Ignored.not)
      Tracked = Untracked.not

    end
  end
end

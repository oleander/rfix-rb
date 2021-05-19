# frozen_string_literal: true

require "dry/types"
require "dry/logic"
require "rugged"

module Rfix
  module Types
    include Dry::Types()
    include Dry::Logic

    Rugged = Instance(::Rugged::Repository)
    Constrained = Dry::Types::Constrained

    Dry::Types.define_builder(:not) do |type|
      Constrained.new(Types::Any, rule: Operations::Negation.new(type.rule))
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
        Untracked = List.constrained(includes: :untracked)
        Index = List.constrained(includes: :index_new)
      end

      Untracked = Staged::Tree.or(Staged::Index).or(Staged::Untracked).and(Ignored.not)
      Tracked = Untracked.not
    end

    Dry::Logic::Predicates.predicate(:truthy?) do |attribute, input|
      !!input.public_send(attribute)
    rescue NoMethodError
      false
    end

    module Path
      include Dry::Types()

      Pathname = Constructor(Pathname) << (String | Instance(Pathname))
      Absolute = Pathname.constrained(truthy: :absolute?)
      Relative = Pathname.constrained(truthy: :relative?)
    end
  end
end

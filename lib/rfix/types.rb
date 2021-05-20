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

      Deleted = %i[deleted worktree_deleted].map do |status|
        List.constrained(includes: status)
      end.reduce(:|)

      Ignored = %i[ignored unmodified].map do |status|
        List.constrained(includes: status)
      end.reduce(:|)

      Untracked = %i[untracked index_new worktree_new].map do |status|
        List.constrained(includes: status)
      end.reduce(:|)

      Tracked = List << (Deleted | Ignored | Untracked).not
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

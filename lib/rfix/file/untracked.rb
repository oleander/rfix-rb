# frozen_string_literal: true

require "dry/types"

module Rfix
  module File
    class Untracked < Base
      module Types
        include Dry::Types()

        Any = Types.Array(Symbol)

        Tree = Any.constrained(includes: :worktree_new)
        Index = Any.constrained(includes: :index_new)

        Status = Tree | Index
      end

      attribute :status, Types::Status

      def untracked?
        true
      end

      def refresh!
        # NOP
      end
    end
  end
end

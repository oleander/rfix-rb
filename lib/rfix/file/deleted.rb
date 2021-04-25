# frozen_string_literal: true

module Rfix
  module File
    class Deleted < Ignored
      attribute :status, Types.Array(Types::Symbol).constrained(includes: :worktree_deleted)

      def deleted?
        true
      end
    end
  end
end

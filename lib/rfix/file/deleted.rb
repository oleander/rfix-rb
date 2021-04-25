# frozen_string_literal: true

module Rfix
  module File
    class Deleted < Base
      attribute :status, Types.Array(Types::Symbol).constrained(includes: :worktree_deleted)

      def deleted?
        true
      end

      def refresh!
        # NOP
      end
    end
  end
end

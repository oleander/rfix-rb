# frozen_string_literal: true

module Rfix
  module File
    class Untracked < Ignored
      attribute :status, Types::Array(Types::Symbol).superset(*UNTRACKED)

      def untracked?
        true
      end
    end
  end
end

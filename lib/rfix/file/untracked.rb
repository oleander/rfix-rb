# frozen_string_literal: true

module Rfix
  module File
    class Untracked < Ignored
      attribute :status, Types.Statuses(*UNTRACKED)

      def untracked?
        true
      end
    end
  end
end

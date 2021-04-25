# frozen_string_literal: true

module Rfix
  module File
    class Staged < Ignored
      attribute :status, Types.Statuses(*STAGED)

      def staged?
        true
      end
    end
  end
end

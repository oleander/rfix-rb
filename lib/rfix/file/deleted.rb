# frozen_string_literal: true

module Rfix
  module File
    class Deleted < Base
      attribute :status, Types::Status::Deleted

      def deleted?
        true
      end

      def refresh!
        # NOP
      end
    end
  end
end

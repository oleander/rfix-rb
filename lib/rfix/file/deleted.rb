# frozen_string_literal: true

module Rfix
  module File
    class Deleted < Base
      attribute :status, Types::Status::Deleted

      def deleted?
        true
      end

      def include?(*)
        false
      end
    end
  end
end

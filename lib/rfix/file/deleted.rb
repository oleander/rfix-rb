# frozen_string_literal: true

module Rfix
  module File
    class Deleted < Base
      ID = "[D]".color(:red).freeze

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

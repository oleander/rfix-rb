# frozen_string_literal: true

module Rfix
  module File
    class Ignored < Base
      attribute :status, Types::Status::Ignored

      def include?(*)
        false
      end

      def refresh!
        # NOP
      end

      def ignored?
        true
      end
    end
  end
end

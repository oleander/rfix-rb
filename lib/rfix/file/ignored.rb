# frozen_string_literal: true

module Rfix
  module File
    class Ignored < Base
      attribute :status, Types::Symbol.enum(*IGNORED)

      def include?(*)
        false
      end

      def refresh!
        # NOP
      end
    end
  end
end

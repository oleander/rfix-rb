# frozen_string_literal: true

module Rfix
  module File
    class Undefined < Base
      def include?(*)
        false
      end

      def ignored?
        true
      end
    end
  end
end

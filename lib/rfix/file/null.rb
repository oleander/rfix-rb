# frozen_string_literal: true

module Rfix
  module File
    module Null
      def include?(*)
        false
      end

      def exists?
        false
      end

      module_function :include?, :exists?
    end
  end
end

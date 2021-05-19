# frozen_string_literal: true

module Rfix
  module Branch
    class Upstream < Base
      def name
        "@{upstream}"
      end

      def to_s
        "upstream"
      end
    end
  end
end

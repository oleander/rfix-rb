# frozen_string_literal: true

module Rfix
  module Branch
    class Upstream < Base
      def resolve
        repository.rev_parse("@{upstream}")
      end

      def to_s
        "upstream"
      end
    end
  end
end

module Rfix
  module Branch
    class Upstream < Base
      def resolve(with:)
        with.rev_parse("@{upstream}")
      end

      def to_s
        "upstream"
      end
    end
  end
end

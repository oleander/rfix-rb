# frozen_string_literal: true

module Rfix
  module Branch
    class Upstream < Base
      def resolve
        repository.rev_parse("@{upstream}")
      rescue Rugged::ConfigError
        raise Error, "No upstream branch defined"
      end

      def to_s
        "upstream"
      end
    end
  end
end

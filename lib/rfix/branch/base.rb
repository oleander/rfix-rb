# frozen_string_literal: true

module Rfix
  module Branch
    class Base
      def resolve(*)
        raise NotYetImplementedError, "#resolved"
      end

      def to_s
        raise NotYetImplementedError, "#to_s"
      end

      def revparse(using:, ref:)
        using.rev_parse(ref)
      rescue Rugged::InvalidError
        raise UnknownBranchError, "Could not find reference {{error:#{ref}}}"
      end
    end
  end
end

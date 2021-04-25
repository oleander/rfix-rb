# frozen_string_literal: true

module Rfix
  module Branch
    class Reference < Base
      attr_reader :reference

      def initialize(reference)
        super()
        @reference = reference
      end

      def resolve(with:)
        Branch::Name.new(reference).resolve(with: with)
      rescue Branch::UnknownBranchError
        revparse(using: with, ref: reference)
      rescue Rugged::InvalidError
        raise Branch::UnknownBranchError, "Branch with reference {{error:#{reference}}} not found"
      end

      alias to_s reference
    end
  end
end

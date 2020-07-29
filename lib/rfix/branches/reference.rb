require_relative "base"

module Rfix
  class Branch::Reference < Branch::Base
    attr_reader :reference

    def initialize(reference)
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

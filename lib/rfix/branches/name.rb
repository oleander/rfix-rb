require_relative "base"

module Rfix
  class Branch::Name < Branch::Base
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def resolve(with:)
      unless branch = with.branches[name]
        raise Branch::UnknownBranchError.new("Could not find branch {{error:#{name}}}")
      end

      with.lookup(with.merge_base(branch.target_id, with.head.target_id))
    rescue Rugged::ReferenceError
      raise Branch::UnknownBranchError.new("Could not find branch {{error:#{name}}}")
    end

    alias to_s name
  end
end

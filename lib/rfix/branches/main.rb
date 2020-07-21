require "rugged"
require_relative "base"

module Rfix
  class Branch::Main < Branch::Base
    KEY = "rfix.main.branch"

    def resolve(with:)
      unless name = with.config[KEY]
        raise Error.new("Please run {{command:rfix setup}} first")
      end

      String.new(name).resolve(with: with)
    end

    def self.set(branch, at: Dir.pwd)
      unless branch.is_a?(String)
        raise Rfix::Error.new("Branch must be a string, got {{error:#{branch.class}}}")
      end

      check = Branch::Name.new(branch)
      repo = Branch.repo(at: at)
      Branch.repo(at: at).config[KEY] = check.branch(using: repo).name
    end

    def self.get(at: Dir.pwd)
      Branch.repo(at: at).config[KEY]
    end

    def to_s
      "configured main branch"
    end
  end
end

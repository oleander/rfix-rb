require "rfix/repository"
require "rfix/error"

module Rfix
  module Branch
    class UnknownBranchError < Rfix::Error
    end

    class NotYetImplementedError < Rfix::Error
    end
  end
end

Pathname(__dir__).glob("branches/*.rb").each(&method(:require))

module Rfix
  module Branch
    UPSTREAM = Branch::Upstream.new
    MAIN     = Branch::Main.new
    HEAD     = Branch::Head.new

    def self.local(at: Dir.pwd)
      repo(at: at).branches.each_name(:local).sort
    end

    def self.repo(at:)
      Rugged::Repository.new(at)
    end
  end
end

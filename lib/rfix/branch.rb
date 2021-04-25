require "rugged"

module Rfix
  module Branch
    UnknownBranchError = Class.new(Error)
    NotYetImplementedError = Class.new(Error)

    UPSTREAM = Upstream.new
    MAIN     = Main.new
    HEAD     = Head.new

    def self.local(at: Dir.pwd)
      repo(at: at).branches.each_name(:local).sort
    end

    def self.repo(at:)
      Rugged::Repository.discover(at)
    end
  end
end

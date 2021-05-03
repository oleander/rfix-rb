# frozen_string_literal: true

module Rfix
  module Branch
    class Main < Name
      KEY = "rfix.main.branch"

      class NoMainBranchSetError < Error
        def initialize
          super("Run 'rfix setup' to set the main branch")
        end
      end

      def self.new(repository: Rugged::Repository.discover)
        unless (name = repository.config[KEY])
          raise NoMainBranchSetError
        end

        super(repository: repository, name: name)
      rescue NoMainBranchSetError
        if repository.head_detached?
          raise Error, "HEAD is detached"
        end

        repository.branches[repository.head.name].then do |branch|
          repository.config[KEY] = branch.name
        end

        retry
      end

      class << self
        if respond_to?(:ruby2_keywords, true)
          ruby2_keywords(:new)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Rfix
  module Branch
    class Main < Name
      KEY = "rfix.main.branch"

      class NoMainBranchSetError < Error
        def initialize
          super("Run {{italic:rfix setup}} to set the main branch")
        end
      end

      def self.new(repository: Rugged::Repository.discover)
        unless (name = repository.config[KEY])
          raise NoMainBranchSet
        end

        super(repository: repository, name: name)
      end
    end
  end
end

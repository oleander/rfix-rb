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

      def self.new(repository:)
        unless name = repository.config[KEY]
          raise NoMainBranchSet.new
        end

        super(repository: repository, name: name)
      end
    end
  end
end

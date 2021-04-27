# frozen_string_literal: true

module Rfix
  module Branch
    class Name < Base
      attribute :name, Types::String

      def resolve
        unless branch = repository.branches[name]
          raise UnknownBranchError.new(branch)
        end

        repository.lookup(repository.merge_base(branch.target_id, repository.head.target_id))
      rescue Rugged::ReferenceError
        raise UnknownBranchError.new(name)
      end

      alias to_s name
    end
  end
end

# frozen_string_literal: true

module Rfix
  module Branch
    class Reference < Name
      def resolve
        super
      rescue UnknownBranchError
        repository.rev_parse(name)
      rescue Rugged::InvalidError
        raise UnknownBranchError.new(name)
      end
    end
  end
end

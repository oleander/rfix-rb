# frozen_string_literal: true

module Rfix
  module Branch
    class Reference < Base
      attribute :name, Types::String

      def resolve
        repository.lookup(repository.rev_parse(name).oid)
      rescue Rugged::Error, Rugged::InvalidError, Rugged::ReferenceError
        raise Error, "Reference #{name.inspect} not found"
      end
    end
  end
end

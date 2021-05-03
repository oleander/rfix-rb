# frozen_string_literal: true

require "pry"

module Rfix
  module Branch
    class Reference < Base
      attribute :name, Types::String

      def resolve
        repository.lookup(repository.rev_parse(name).oid)
      rescue Rugged::Error, Rugged::InvalidError
        binding.pry
        raise Error, name
      end
    end
  end
end

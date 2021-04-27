# frozen_string_literal: true

require "dry/struct"

module Rfix
  module Branch
    class Base < Dry::Struct
      attribute :repository, Types::Rugged

      class UnknownBranchError < Error
        def initialize(name)
          super("Could not find branch {{error:#{name}}}")
        end
      end

      # @abstract
      def resolve(*)
        raise NotYetImplementedError, self.class.name
      end

      # @abstract
      def to_s
        raise NotYetImplementedError, self.class.name
      end
    end
  end
end

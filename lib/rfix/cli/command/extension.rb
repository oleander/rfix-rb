# frozen_string_literal: true

require "dry/core/constants"

module Rfix
  module CLI
    module Command
      class Extension < Module
        include Dry::Core::Constants

        def initialize(method, &block)
          define_method(method, &block)
        end

        def self.call(source, method, value = Undefined, &block)
          unless block_given?
            return call(source, method, &value.method(:itself))
          end

          source.include(new(method, &block))
        end
      end
    end
  end
end

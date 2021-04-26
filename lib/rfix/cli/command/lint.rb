# frozen_string_literal: true

module Rfix
  module CLI
    module Command
      class Lint < Base
        def call(branch:, **params)
          define(Branch::Reference.new(branch), **params)
        end
      end
    end
  end
end

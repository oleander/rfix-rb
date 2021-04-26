# frozen_string_literal: true

module Rfix
  module CLI
    module Command
      class Lint < Base
        argument :branch, type: :string, required: true

        def call(branch:, **params)
          define(Rfix::Branch::Reference.new(branch), **params)
        end
      end
    end
  end
end

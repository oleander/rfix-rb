# frozen_string_literal: true

module Rfix
  module CLI
    module Command
      class Lint < Base
        option :auto_correct_all, type: :boolean, default: false
        option :auto_correct, type: :boolean, default: false
        argument :branch, type: :string, required: true

        def call(branch:, **params)
          define(Rfix::Branch::Reference.new(name: branch), **params, lint: true)
        end
      end
    end
  end
end

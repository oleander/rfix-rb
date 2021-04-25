# frozen_string_literal: true

require "dry/cli"

module Rfix
  module CLI
    module Command
      extend Dry::CLI::Registry

      register "lint", Lint
    end
  end
end

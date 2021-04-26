# frozen_string_literal: true

require "dry/cli"

module Rfix
  module CLI
    module Command
      extend Dry::CLI::Registry

      register "origin", Origin
      register "branch", Branch
      register "local", Local
      register "setup", Setup
      register "lint", Lint
      register "info", Info
      register "help", Help
    end
  end
end

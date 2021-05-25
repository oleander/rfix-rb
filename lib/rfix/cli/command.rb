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
      register "all", All
      register "status", Status
      
      # register "help", Help

      def setup
        Dry::CLI.new(self).call
      rescue Error => e
        abort e.message
      else
        exit 0
      end

      module_function :setup
    end
  end
end

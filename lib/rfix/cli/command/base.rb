# frozen_string_literal: true

require "dry/core/constants"

module Rfix
  module CLI
    module Command
      class Base < Dry::CLI::Command
        include Dry::Core::Constants
      end
    end
  end
end

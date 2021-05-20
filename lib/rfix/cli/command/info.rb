# frozen_string_literal: true

require "rubocop"

module Rfix
  module CLI
    module Command
      class Info < Base
        def call(**)
          puts "Rubocop: #{RuboCop::Version.version}"
          puts "Rfix: #{VERSION}"
        end
      end
    end
  end
end

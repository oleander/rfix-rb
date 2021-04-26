# frozen_string_literal: true

require "rubocop"

module Rfix
  module CLI
    module Command
      class Config < RuboCop::CommentConfig
        include Log

        def initialize(rfix, *rest)
          super(*rest)
          @rfix = rfix
        end

        def cop_enabled_at_line?(_, line)
          super && @rfix.include?(processed_source.file_path, line)
        rescue StandardError => e
          puts e.message
        end
      end
    end
  end
end

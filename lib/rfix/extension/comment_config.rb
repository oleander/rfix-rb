# frozen_string_literal: true

require "rubocop"
require "rainbow"
require "rfix/log"

module Rfix
  module Extension
    module CommentConfig
      include Log # TODO: Remove
      # Called by RuboCop on every line to see
      # if its suppose to run against it or not
      def cop_enabled_at_line?(_cop, line)
        Rfix.enabled?(processed_source.file_path, line) && super
      rescue StandardError
        say_abort "[Enabled] #{$ERROR_INFO}"
      end
    end
  end
end

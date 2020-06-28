# frozen_string_literal: true

# rubocop:enable Style/Semicolon

require "rubocop"
require "rainbow"
require "rfix/log"

module Rfix::Ext
  module CommentConfig
    include Rfix::Log # TODO: Remove
    # Called by RuboCop on every line to see
    # if its suppose to run against it or not
    def cop_enabled_at_line?(_cop, line)
      Rfix.enabled?(processed_source.file_path, line) && super
    rescue StandardError
      say_abort "[Rfix::Enabled] #{$ERROR_INFO}"
    end
  end

  module Runner
    # include Rfix::Log # TODO: Remove
    # Called _after_ @source has been 'auto fixed' by Rubocop
    # def check_for_infinite_loop(source, offences)
    #   Rfix.refresh!(source); super
    # rescue StandardError
    #   say_abort "[Rfix::Refresh] #{$!}"
    # end
  end
end

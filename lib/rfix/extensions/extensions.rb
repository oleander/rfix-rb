# frozen_string_literal: true

require "rubocop"
require "rainbow"

module Rfix::Ext
  module CommentConfig
    # Called by RuboCop on every line to see
    # if its suppose to run against it or not
    def cop_enabled_at_line?(_cop, line)
      Rfix.enabled?(processed_source.file_path, line) && super
    rescue StandardError
      say_error "[Rfix::Enabled] #{$!}"
    end
  end

  module Runner
    # Called _after_ @source has been 'auto fixed' by Rubocop
    def check_for_infinite_loop(source, offences)
      # rubocop:disable Style/Semicolon
      Rfix.refresh!(source); super
      # rubocop:enable Style/Semicolon
    rescue StandardError
      say_error "[Rfix::Refresh] #{$!}"
    end
  end

  module Options
    # Appends custom --args to RuboCop CLI
    def define_options
      super.tap do |options|
        @ons.each do |args, block|
          option(options, *args, &block)
        end
      end
    end

    # Helper method used by rfix to append cli --args to Rubocop
    def on(*args, &block)
      @ons ||= []
      @ons += [[args, block]]
    end
  end
end

# frozen_string_literal: true

require "rubocop"
require "rainbow"

module Rfix::Ext
  module CommentConfig
    # Called by RuboCop on every line to see
    # if its suppose to run against it or not
    def cop_enabled_at_line?(_cop, line)
      Rfix.enabled?(processed_source.file_path, line) && super
    end
  end

  module Runner
    # Called _after_ @source has been 'auto fixed' by Rubocop
    def check_for_infinite_loop(source, offences)
      Rfix.refresh!(source); super # TODO: Before or after?
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

  module Offense
    def where
      line.to_s + ":" + real_column.to_s
    end

    def info
      message.split(": ", 2).last.delete("\n")
    end

    def msg
      CLI::UI.resolve_text("{{italic:#{info}}}", truncate_to: CLI::UI::Terminal.width - 10)
    end

    def code
      message.split(": ", 2).first
    end

    def star
      Rainbow("⭑")
    end

    def cross
      Rainbow("✗")
    end

    def check
      Rainbow("✓")
    end

    def level
      colors = {
        refactor: star.lightcyan,
        convention: star.lightblue,
        warning: star.lightyellow,
        error: cross.indianred,
        fatal: cross.lightsalmon
      }

      colors[severity.name]
    end

    def icon
      return check.green if corrected?
      return check.lightgreen if correctable?
      cross.indianred
    end
  end
end

RuboCop::Options.prepend(Rfix::Ext::Options)
RuboCop::Runner.prepend(Rfix::Ext::Runner)
RuboCop::CommentConfig.prepend(Rfix::Ext::CommentConfig)
RuboCop::Cop::Offense.prepend(Rfix::Ext::Offense)

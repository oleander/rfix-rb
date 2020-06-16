# frozen_string_literal: true

require "rubocop"

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

    # def process_file(file)
    #   Rfix.spin.add(file) { super }
    # end

    # def inspect_files(files)
    #   files.uniq.each do |file|
    #     Rfix.spin.add(Rfix.to_relative(path: file)) do
    #       sleep(0.4)
    #       file_offenses(file)
    #     end
    #   end
    #
    #   Rfix.spin.wait
    #   super
    # end
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

RuboCop::Options.prepend(Rfix::Ext::Options)
RuboCop::Runner.prepend(Rfix::Ext::Runner)
RuboCop::CommentConfig.prepend(Rfix::Ext::CommentConfig)

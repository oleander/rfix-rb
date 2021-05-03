# frozen_string_literal: true

require "active_support/core_ext/module/concerning"
require "dry/core/constants"
require "rubocop"
require "rainbow"
require "rugged"

require "rfix/extension/pastel"
require "rfix/extension/strings"

module Rfix
  module CLI
    module Command
      class Base < Dry::CLI::Command
        include Log
        include Dry::Core::Constants

        class RuboCop::CommentConfig
          concerning :Verification, prepend: true do
            def cop_enabled_at_line?(cop, line)
              repository.include?(processed_source.file_path, line) && super(cop, line)
            rescue StandardError => e
              abort e.full_message(highlight: true)
            end
          end
        end

        option :formatters, type: :array, default: ["Rfix::Formatter"]
        option :format, type: :string, default: "Rfix::Formatter"
        option :auto_correct_all, type: :boolean, default: true
        option :auto_correct, type: :boolean, default: true
        option :cache, type: :boolean, default: true
        option :debug, type: :boolean, default: false
        option :only_recognized_file_types, type: :boolean, default: true
        option :force_exclusion, type: :boolean, default: true

        private

        def define(reference, args: Undefined, **params)
          handler = Rfix::Repository.new(
            repository: reference.repository,
            reference: reference
          )

          RuboCop::CommentConfig.class_eval do
            concerning :Repository do
              define_method(:repository, &handler.method(:itself))
            end
          end

          Undefined.default(args, handler.paths).then do |paths|
            RuboCop::CLI::Environment.new(params, RuboCop::ConfigStore.new, paths)
          end.then do |env|
            RuboCop::CLI::Command::ExecuteRunner.new(env).run
          end
        end
      end
    end
  end
end

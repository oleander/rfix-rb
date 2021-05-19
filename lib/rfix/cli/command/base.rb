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

        module ::RuboCop
          class CommentConfig
            concerning :Verification, prepend: true do
              def cop_enabled_at_line?(_, line)
                super && repository.include?(processed_source.file_path, line)
              rescue StandardError => e
                abort e.full_message(highlight: true)
              end
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
        option :no_cache, type: :boolean, default: false
        option :force_exclusion, type: :boolean, default: true

        private

        def define(reference, args: Undefined, **params)
          handler = Rfix::Repository.new(
            repository: reference.repository,
            reference: reference
          )

          ::RuboCop::CommentConfig.class_eval do
            concerning :Repository do
              define_method(:repository, &handler.method(:itself))
            end
          end

          Formatter.class_eval do
            define_method(:repository, &handler.method(:itself))
            define_method(:debug?) { params.fetch(:debug, false) }
          end

          config = ::RuboCop::ConfigStore.new.tap do |config|
            ::RuboCop::ConfigLoader.configuration_file_for(handler.workdir).then do |loader|
              config.options_config = loader
            rescue ::RuboCop::Cop::AmbiguousCopName => e
              abort e.message
            end
          end

          Undefined.default(args, handler.paths).then do |paths|
            ::RuboCop::CLI::Environment.new(params, config, paths)
          end.then do |env|
            ::RuboCop::CLI::Command::ExecuteRunner.new(env).run
          end
        end
      end
    end
  end
end

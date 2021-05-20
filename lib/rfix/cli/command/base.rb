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

        option :formatters, type: :array, default: ["Rfix::Formatter"]
        option :format, type: :string, default: "Rfix::Formatter"
        option :auto_correct_all, type: :boolean, default: true
        option :auto_correct, type: :boolean, default: true
        option :parallel, type: :boolean, default: true
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

          RuboCop::CommentConfig.class_eval do
            concerning :Repository do
              define_method(:repository, &handler.method(:itself))
            end
          end

          Formatter.class_eval do
            define_method(:repository, &handler.method(:itself))
            define_method(:debug?) { params.fetch(:debug, false) }
          end

          paths = handler.paths

          RuboCop::Options.new.parse(ARGV).then do |user_defined_options, user_defined_paths|
            params.merge!(user_defined_options)

            unless user_defined_paths.empty?
              paths.replace(user_defined_paths)
            end
          end

          config = RuboCop::ConfigStore.new.tap do |config_store|
            RuboCop::ConfigLoader.configuration_file_for(handler.workdir).then do |loader|
              config_store.options_config = loader
            rescue RuboCop::Cop::AmbiguousCopName => e
              abort e.message
            end
          end

          if params[:no_cache]
            RuboCop::ResultCache.cleanup(config, true)
            XDG::Config.new.home.then do |cache_path|
              cache_path.delete if cache_path.exist?
            end
          end

          env = RuboCop::CLI::Environment.new(params, config, paths)
          RuboCop::CLI::Command::ExecuteRunner.new(env).run
        end
      end
    end
  end
end

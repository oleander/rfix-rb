# frozen_string_literal: true

require "active_support/core_ext/module/concerning"
require "dry/core/constants"
require "rubocop"
require "rainbow"
require "rugged"

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
        option :parallel, type: :boolean, default: false
        option :cache, type: :boolean, default: true
        option :debug, type: :boolean, default: false
        option :only_recognized_file_types, type: :boolean, default: true
        option :no_cache, type: :boolean, default: false
        option :force_exclusion, type: :boolean, default: true

        private

        def define(reference, args: Undefined, **params)
          handler = Rfix::Repository.new(
            current_path: Pathname.pwd.relative_path_from(reference.repository.workdir),
            repository: reference.repository,
            reference: reference
          )

          RuboCop::CommentConfig.class_eval do
            concerning :Repository do
              define_method(:repository, &handler.method(:itself))
            end
          end

          paths = handler.paths

          variadic_args = Undefined.default(args, EMPTY_ARRAY)
          RuboCop::Options.new.parse(variadic_args).then do |user_defined_options, user_defined_paths|
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
              cache_path.rmtree if cache_path.exist?
            end
          end

          params.merge!(repository: handler)

          env = RuboCop::CLI::Environment.new(params, config, paths)
          RuboCop::CLI::Command::ExecuteRunner.new(env).run
        end
      end
    end
  end
end

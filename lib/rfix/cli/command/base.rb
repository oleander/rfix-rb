# frozen_string_literal: true

require "dry/core/constants"
require "rubocop"
require "rugged"

module Rfix
  module CLI
    module Command
      class Base < Dry::CLI::Command
        include Dry::Core::Constants

        option :formatters, type: :array, default: ["Rfix::Formatter"]
        option :format, type: :string, default: "Rfix::Formatter"
        option :auto_correct_all, type: :boolean, default: true
        option :auto_correct, type: :boolean, default: true
        option :cache, type: :boolean, default: true
        option :debug, type: :boolean, default: false
        # option :config, type: :string, default: "/Users/loleander/Code/rfix-rb/.rubocop.yml"

        private

        def define(reference, cache: true, args: [], **params)
          pp params
          store      = RuboCop::ConfigStore.new
          options    = RuboCop::Options.new

          handler = Rfix::Repository.new(
            repository: reference.repository,
            reference: reference
          )

          Extension.call(RuboCop::Formatter::SimpleTextFormatter, :repository, handler)
          Extension.call(RuboCop::ProcessedSource, :repository, handler)

          Extension.call(RuboCop::ProcessedSource, :comment_config) do
            Config.new(repository, self)
          end

          unless cache
            RuboCop::ResultCache.cleanup(store, true)
          end

          env = RuboCop::CLI::Environment.new(params, store, EMPTY_ARRAY)

          exit RuboCop::CLI::Command::ExecuteRunner.new(env).run
          resuce Rfix::Error, TypeError, Psych::SyntaxError => e
          say! e.to_s
        end
      end
    end
  end
end

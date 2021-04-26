# frozen_string_literal: true

require "rugged"
require "rubocop"

module Rfix
  module CLI
    module Command
      class Lint < Base
        option :formatters, type: :array, default: ["Rfix::Formatter"]
        option :format, type: :string, default: "Rfix::Formatter"
        option :auto_correct_all, type: :boolean, default: true
        option :auto_correct, type: :boolean, default: true
        option :cache, type: :boolean, default: true
        option :debug, type: :boolean, default: false

        option :branch, type: :string

        def call(cache:, args: [], branch: "master", **params)
          reference  = Branch::Reference.new(branch)
          repository = Rugged::Repository.discover
          store      = RuboCop::ConfigStore.new
          options    = RuboCop::Options.new

          handler = Rfix::Repository.new(
            repository: repository,
            reference: reference
          )

          RuboCop::ProcessedSource.include(Module.new do
            define_method(:comment_config) do
              @comment_config ||= Config.new(handler, self)
            end
          end)

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

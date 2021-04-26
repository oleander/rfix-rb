# frozen_string_literal: true

require "rugged"
require "rubocop"

module Rfix
  module CLI
    module Command
      class Lint < Base
        option :formatters, type: :array, default: ["Rfix::Formatter"]
        option :force_exclusion, type: :boolean, default: true
        option :auto_correct, type: :boolean, default: true
        option :branch, type: :string


        def call(args: [], branch: "master", **params)
          options  = RuboCop::Options.new
          store    = RuboCop::ConfigStore.new
          repository = Rugged::Repository.discover

          store.for(repository.path)

          handler = Rfix::Repository.new(
            repository: repository,
            load_untracked: true,
            reference: Branch::Reference.new(branch),
            paths: args
          )

          RuboCop::ProcessedSource.include(Module.new do
            define_method(:comment_config) do
              @comment_config ||= Config.new(handler, self)
            end
          end)

          new_params, paths = options.parse(handler.paths)

          env = RuboCop::CLI::Environment.new(new_params.merge(params), store, paths)

          exit RuboCop::CLI::Command::ExecuteRunner.new(env).run
          resuce Rfix::Error, TypeError, Psych::SyntaxError => e
          say! e.to_s
        end
      end
    end
  end
end

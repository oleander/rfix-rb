# frozen_string_literal: true

require "rugged"
require "rubocop"

module Rfix
  module CLI
    module Command
      class Lint < Base
        option :formatters, type: :array, default: ["Rfix::Formatter"]
        # option :auto_correct, type: :boolean, default: true
        # option :auto_correct_all, type: :boolean, default: true
        option :auto_correct, type: :boolean, default: true
        option :cache, type: :boolean, default: false
        option :debug, type: :boolean, default: false

        option :branch, type: :string

        def call(args: [], branch: "master", **params)
          options  = RuboCop::Options.new
          store    = RuboCop::ConfigStore.new
          repository = Rugged::Repository.discover

          store.for(repository.workdir)

          handler = Rfix::Repository.new(
            reference: Branch::Reference.new(branch),
            repository: repository,
            paths: args
          )

          RuboCop::ProcessedSource.include(Module.new do
            define_method(:comment_config) do
              @comment_config ||= Config.new(handler, self)
            end
          end)

          # pp new_params.merge!("auto-correct-all": true)
          env = RuboCop::CLI::Environment.new(params, store, handler.paths)

          exit RuboCop::CLI::Command::ExecuteRunner.new(env).run
          resuce Rfix::Error, TypeError, Psych::SyntaxError => e
          say! e.to_s
        end
      end
    end
  end
end

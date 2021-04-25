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
          # errors = [RuboCop::Runner::InfiniteCorrectionLoop, RuboCop::Error]
          # errors = [Rfix::Error, TypeError, Psych::SyntaxError]
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

          env = RuboCop::CLI::Environment.new(params, store, handler.paths)

          exit RuboCop::CLI::Command::ExecuteRunner.new(env).run
        resuce Rfix::Error, TypeError, Psych::SyntaxError => e
          say_abort e.to_s
        end
      end
    end
  end
end

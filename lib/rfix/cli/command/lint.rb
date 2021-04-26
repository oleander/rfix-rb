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

        Config = Class.new(RuboCop::CommentConfig) do
          def initialize(rfix, *rest)
            super(*rest)
            @rfix = rfix
          end

          def cop_enabled_at_line?(_, line)
            @rfix.include?(processed_source.file_path, line).tap do |value|
              # pp processed_source.file_path
            end
          rescue StandardError => e
            puts e.message
          end
        end

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

          RuboCop::ProcessedSource.include(Module.new do
            define_method(:comment_config) do
              @comment_config ||= Config.new(handler, self)
            end
          end)

          new_params, paths = options.parse(handler.paths)

          env = RuboCop::CLI::Environment.new(new_params.merge(params), store, paths)

          exit RuboCop::CLI::Command::ExecuteRunner.new(env).run
          resuce Rfix::Error, TypeError, Psych::SyntaxError => e
          say_abort e.to_s
        end
      end
    end
  end
end

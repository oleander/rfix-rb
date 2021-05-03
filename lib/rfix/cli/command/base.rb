# frozen_string_literal: true

require "dry/core/constants"
require "active_support/all"
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

          RuboCop::CommentConfig.prepend(Module.new do
            define_singleton_method(:prepended) do |base|
              super(base)

              base.define_singleton_method(:cop_enabled_at_line?) do |cop, line|
                super(cop, line) && handler.include?(processed_source.file_path, line)
              rescue StandardError => e
                abort e.full_message(highlight: true)
              end
            end
          end)

          Undefined.default(args, handler.paths).then do |paths|
            RuboCop::CLI::Environment.new(params, RuboCop::ConfigStore.new, paths)
          end.then do |env|
            exit RuboCop::CLI::Command::ExecuteRunner.new(env).run
          end
        rescue Rfix::Error, TypeError, Psych::SyntaxError => e
          say! e.message
        end
      end
    end
  end
end

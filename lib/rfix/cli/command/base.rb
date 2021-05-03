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

          RuboCop::CommentConfig.class_eval do
            concerning :Verification, prepend: true do
              define_method(:cop_enabled_at_line?) do |cop, line|
                super(cop, line) && handler.include?(processed_source.file_path, line)
              rescue StandardError => e
                abort e.full_message(highlight: true)
              end
            end
          end

          Undefined.default(args, handler.paths).then do |paths|
            RuboCop::CLI::Environment.new(params, RuboCop::ConfigStore.new, paths)
          end.then do |env|
            exit RuboCop::CLI::Command::ExecuteRunner.new(env).run
          end
        rescue Rfix::Error, TypeError, Psych::SyntaxError => e
          abort Rainbow(e.message).red
        end
      end
    end
  end
end

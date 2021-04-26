# frozen_string_literal: true

# https://www.rubydoc.info/gems/rubocop/RuboCop/OptionsHelp

require "rugged"
require "rubocop"

options  = RuboCop::Options.new
store    = RuboCop::ConfigStore.new
repository = Rugged::Repository.discover

params = {
  fix_layout: true,
  list_target_files: false,
  auto_correct_all: true,
  # auto_correct: "true",
  cache: "false",
  debug: true,
  extra_details: true
}

RuboCop::ResultCache.cleanup(store, true)

env = RuboCop::CLI::Environment.new(params, store, [])

exit RuboCop::CLI::Command::ExecuteRunner.new(env).run

# frozen_string_literal: true

require "rfix"
require "aruba/rspec"

Aruba.configure do |config|
  config.command_launcher = :spawn
  config.allow_absolute_paths = false
  config.fixtures_directories = ["vendor", "spec/fixtures"]
  config.command_runtime_environment = {
    "OVERCOMMIT_DISABLE" => "1",
    "GIT_TEMPLATE_DIR" => ""
  }
end

Dir[File.join(__dir__, "../spec/support/*.rb")].each(&method(:require))

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.include Rfix::Cmd
  config.include Rfix::Log
  config.order = :random

  config.disable_monkey_patching!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

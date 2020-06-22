# frozen_string_literal: true

require "rfix"
require "aruba/rspec"

Aruba.configure do |config|
  config.allow_absolute_paths = true
  config.activate_announcer_on_command_failure = [:stdout, :stderr]
  config.command_runtime_environment = {
    "OVERCOMMIT_DISABLE" => "1",
    "GIT_TEMPLATE_DIR" => ""
  }
end

Dir[File.join(__dir__, "support/**/*.rb")].each(&method(:require))

setup = SetupGit.setup

RSpec.shared_context "setup", shared_context: :metadata  do
  subject(:git) { Git.clone(setup.bundle_file, "base", path: git_path) }
  let(:git_path) { Dir.mktmpdir("repos", expand_path(".")) }
  let(:status) { git.status }

  around do |example|
    cd(git.dir.to_s) do
      example.run
    end
  end
end

RSpec.configure do |config|
  config.include Rfix::Cmd
  config.include Rfix::Log
  config.include Rfix::Git
  config.include Aruba::Api
  config.include Rfix::Support

  config.order = :random
  config.example_status_persistence_file_path = ".rspec_status"
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!

  unless ENV["CI"]
    config.filter_run focus: true
    config.run_all_when_everything_filtered = true
  end

  config.append_after(:suite) do
    setup.teardown
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

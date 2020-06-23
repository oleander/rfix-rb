# frozen_string_literal: true

require "rfix"
require "aruba/rspec"
require "fileutils"

Aruba.configure do |config|
  config.allow_absolute_paths = true
  config.activate_announcer_on_command_failure = [:stdout, :stderr]
  config.command_runtime_environment = {
    "OVERCOMMIT_DISABLE" => "1",
    "GIT_TEMPLATE_DIR" => ""
  }
end

Dir[File.join(__dir__, "support/**/*.rb")].each(&method(:require))

setup = SetupGit.setup!

RSpec.shared_context "setup", shared_context: :metadata  do
  subject(:git) { setup.git }
  let(:git_path) { setup.git_path }
  let(:rp) { SetupGit::RP }
  let(:status) { git.status }
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

  config.around(:each) do |example|
    Rfix.init!
    setup.reset!

    Dir.chdir(setup.git_path) do
      cd(setup.git_path) do
        example.run
      end
    end
  end

  config.prepend_before(:suite) do
    setup.clone!
    Rfix.set_root(setup.git_path)
  end

  config.append_after(:suite) do
    setup.teardown!
  end

  unless ENV["CI"]
    config.filter_run focus: true
    config.run_all_when_everything_filtered = true
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

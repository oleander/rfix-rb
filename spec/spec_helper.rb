# frozen_string_literal: true

require "rfix"
require "aruba/rspec"

Aruba.configure do |config|
  config.command_launcher = :spawn
  config.allow_absolute_paths = true
  config.fixtures_directories = ["vendor", "spec/fixtures"]
  config.command_runtime_environment = {
    "OVERCOMMIT_DISABLE" => "1",
    "GIT_TEMPLATE_DIR" => ""
  }
end

Dir[File.join(__dir__, "../spec/support/*.rb")].each(&method(:require))

dst_repo = File.join(__dir__, "..", "tmp", "test-repo")
src_repo = File.join(__dir__, "..", "vendor", "oleander/git-fame-rb")

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.include Rfix::Cmd
  config.include Rfix::Log
  config.include Rfix::Git
  config.include Rfix::Support
  config.include Aruba::Api

  config.order = :random
  unless ENV["CI"]
    config.filter_run focus: true
    config.run_all_when_everything_filtered = true
  end
  config.disable_monkey_patching!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    FileUtils.mkdir_p(dst_repo)
    FileUtils.copy_entry(src_repo, dst_repo, true, true, true)
    Rfix::Git.git("branch", "-d", "test", root: dst_repo, quiet: true)
  end

  config.around do |example|
    data_repo_git = File.join(src_repo, ".git/")
    test_repo_git = File.join(dst_repo, ".git")

    Rfix::Git.git("clean", "-f", "-d", root: dst_repo)
    Rfix::Git.git("checkout", ".", root: dst_repo)

    cmd("rsync", "-a", "--stats", "--delete", data_repo_git, test_repo_git, quiet: true)

    cd(dst_repo) { example.run }
  end
end

# frozen_string_literal: true

require "rfix"
require "aruba/rspec"

Aruba.configure do |config|
  # config.command_launcher = :in_process
  config.allow_absolute_paths = true
  config.activate_announcer_on_command_failure = [:stdout, :stderr]
  config.command_runtime_environment = {
    "OVERCOMMIT_DISABLE" => "1",
    "GIT_TEMPLATE_DIR" => ""
  }
end

Dir[File.join(__dir__, "../spec/support/*.rb")].each(&method(:require))

src_repo = File.join(__dir__, "..", "tmp", "src-repo")
bundle_path = File.join(__dir__, "..", "tmp", "snapshot.bundle")
org_repo = File.join(__dir__, "..", "vendor", "oleander/git-fame-rb")

RSpec.configure do |config|
  config.include Rfix::Cmd
  config.include Rfix::Log
  config.include Rfix::Git
  config.include Aruba::Api
  config.include Rfix::Support

  config.order = :random
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

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

  config.before(:suite) do
    FileUtils.mkdir_p(src_repo)

    FileUtils.copy_entry(org_repo, src_repo, true, true, true)

    Rfix::Git.git("checkout", "master", root: src_repo)
    Rfix::Git.git("reset", "--hard", "27fec8", root: src_repo)
    Rfix::Git.git("branch", "-D", "test", root: src_repo, quiet: true)
    Rfix::Git.git("checkout", "-b", "test", root: src_repo)
    Rfix::Git.git("reset", "--hard", "a9b9c25", root: src_repo)
    Rfix::Git.git("checkout", "master", root: src_repo)

    Rfix::Git.git("bundle", "create", bundle_path, "--all", root: src_repo)

    if Rfix::Git.dirty?(src_repo)
      say_abort "[Src:1] Dirty repo on init {{italic:#{src_repo}}}"
    end
  end

  # This is cleaned up by aruba
  config.around(:each) do |example|
    repo = Dir.mktmpdir("rspec", expand_path("."))
    cmd("git", "clone", bundle_path, repo, "--branch", "master")
    cd(repo) { example.run }
  end
end

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

src_repo = File.join(__dir__, "..", "tmp", "src-repo")
bundle_path = File.join(__dir__, "..", "tmp", "snapshot.bundle")
org_repo = File.join(__dir__, "..", "vendor", "oleander/git-fame-rb")

setup = SetupGit.setup!

def init!(root)
  Rfix.set_root(root)
  Rfix.init!
  Rfix.set_main_branch("master")
  system 'git config user.email "me@example.com"'
  system 'git config user.name "John Doe"'
end

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

  config.around(:each, type: :git) do |example|
    setup.reset!
    init!(setup.git_path)
    Dir.chdir(setup.git_path) do
      cd(setup.git_path) do
        example.run
      end
    end
  end

  config.prepend_before(:suite, type: :git) do
    setup.clone!
  end

  config.append_after(:suite, type: :git) do
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

  config.before(:suite, type: :aruba) do
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
  config.around(:each, type: :aruba) do |example|
    repo = Dir.mktmpdir("rspec", expand_path("."))
    cmd("git", "clone", bundle_path, repo, "--branch", "master")
    init!(repo)
    cd(repo) { example.run }
  end
end

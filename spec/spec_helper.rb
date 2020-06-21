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

dst_repo = File.join(__dir__, "..", "tmp", "dst-repo")
src_repo = File.join(__dir__, "..", "tmp", "src-repo")
org_repo = File.join(__dir__, "..", "vendor", "oleander/git-fame-rb")
src_repo_git = File.join(src_repo, ".git/")
dst_repo_git = File.join(dst_repo, ".git")

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
    FileUtils.mkdir_p(src_repo)

    FileUtils.copy_entry(org_repo, src_repo, true, true, true)

    Rfix::Git.git("checkout", "master", root: src_repo)
    Rfix::Git.git("reset", "--hard", "27fec8", root: src_repo)
    Rfix::Git.git("branch", "-D", "test", root: src_repo, quiet: true)
    Rfix::Git.git("checkout", "-b", "test", root: src_repo)
    Rfix::Git.git("reset", "--hard", "a9b9c25", root: src_repo)
    Rfix::Git.git("checkout", "master", root: src_repo)

    if Rfix::Git.dirty?(src_repo)
      say_abort "[Src:1] Dirty repo on init {{italic:#{src_repo}}}"
    end

    FileUtils.copy_entry(src_repo, dst_repo, true, true, true)

    if Rfix::Git.dirty?(dst_repo)
      say_abort "[Dst:1] Dirty repo on init {{italic:#{dst_repo}}}"
    end
  end

  config.around do |example|
    # if Rfix::Git.dirty?(dst_repo)
    #   say Rfix::Git.git("status", root: dst_repo).join("\n")
    #   say_abort "[Dst:2] Dirty repo on init {{italic:#{dst_repo}}}"
    # end

    cd(dst_repo) { example.run }

    # cmd("rsync", "-a", "-W", src_repo_git, dst_repo_git)
    FileUtils.copy_entry(src_repo_git, dst_repo_git, true, true, true)

    Rfix::Git.git("clean", "-f", "-d", root: dst_repo)
    Rfix::Git.git("checkout", ".", root: dst_repo)
  end
end

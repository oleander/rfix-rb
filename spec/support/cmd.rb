# frozen_string_literal: true

require "shellwords"

module Rfix::Support
  def setup_test_branch(upstream: false)
    cmd "git checkout master"
    cmd "git reset --hard 27fec8"
    cmd "git checkout -b test"
    cmd "git reset --hard a9b9c25"
    if branch = upstream
      cmd "git branch --set-upstream-to origin/#{branch}"
    end
  end

  def add_file_and_commit(file: "file.rb")
    add_file(file: file)
    cmd "git add #{file}"
    cmd 'git config user.email "you@example.com"'
    cmd 'git config user.name "Your Name"'
    cmd 'git commit --author="John Doe <john@doe.org>" -m "my commit"'
  end

  def ref_for_branch(branch: "master")
    cmd("git", "rev-parse", branch).first
  end

  def add_file(file: "file.rb")
    cmd %(echo '"hello"' > #{file})
  end

  def no_changed_files
    cmd("git status --short | wc -l").first.to_i
  end

  def origin_cmd(**args)
    default_cmd("origin", **args)
  end

  def local_cmd(**args)
    default_cmd("local", **args)
  end

  def lint_cmd(**args)
    default_cmd("lint", dry: false, **args)
  end

  def branch_cmd(branch: "master", **args)
    default_cmd("branch #{branch}", **args)
  end

  def root_path
    File.expand_path("..", __dir__)
  end

  def config_path
    Shellwords.escape File.join(root_path, "fixtures/rubocop.yml")
  end

  def default_cmd(cmd, dry: true, untracked: false, help: false)
    cmd = cmd.dup
    cmd << " --dry" if dry
    cmd << " --untracked" if untracked
    cmd << " --help" if help
    cmd << " --list-files"
    cmd << " --config #{config_path}"
    run_command_and_stop("rfix #{cmd}", fail_on_error: false)
  end
end

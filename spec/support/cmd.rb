# frozen_string_literal: true

require "shellwords"

module Rfix::Support
  def setup_test_branch(upstream: false)
    checkout("test")

    if branch = upstream
      cmd "git branch --set-upstream-to origin/#{branch}"
    end
  end

  def commits(since:)
    cmd("git rev-list #{since}..HEAD | wc -l").first.to_i
  end

  def current_commit
    cmd("git rev-parse HEAD").first
  end

  def dump!
    git.status.dump!
  end

  def random_file_name(ext: ".rb")
    ('a'..'z').to_a.shuffle[0,8].join + ext
  end

  def add_rubocop_config
    file_name = ".rubocop.yml"
    expect do
      copy "%/rubocop.yml", file_name
      git.add(".rubocop.yml")
      git.commit("Add RuboCop Config")
    end.to change { total_commits }.by(1)
    file_name
  end

  def add_valid_file
    file_name = random_file_name
    expect do
      copy "%/valid.rb", file_name
      git.add(file_name)
      git.commit("Add Valid Ruby File")
    end.to change { total_commits }.by(1)
    file_name
  end

  def checkout(*branches)
    branches.each do |branch|
      git.branch(branch.to_s).checkout
    end
  end

  def total_commits
    cmd("git rev-list --all --count").first.to_i
  end

  def upstream(branch)
    cmd "git branch --set-upstream-to #{branch}"
  end

  def f(type)
    Change.new(self, git, type)
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
    default_cmd("lint", **args)
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

  def dirty?
    !cmd_succeeded?("git diff --quiet")
  end

  def default_cmd(cmd, root: nil, dry: true, untracked: false, help: false, debug: false, main_branch: "master")
    cmd = cmd.dup
    cmd << " --dry" if dry
    cmd << " --untracked" if untracked
    cmd << " --help" if help
    cmd << " --root #{root}" if root
    cmd << " --main-branch #{main_branch}"
    cmd << " --cache false"
    cmd << " --test"
    # cmd << " --debug" if debug
    # cmd << " --no-color"
    # cmd << " --list-files"
    cmd << " --config #{config_path}"

    run_command_and_stop("rfix #{cmd}", fail_on_error: false)
  end

  private

end

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

  def random_file_name(ext: ".rb")
    ('a'..'z').to_a.shuffle[0,8].join + ext
  end

  def add_rubocop_config
    file_name = ".rubocop.yml"
    expect do
      copy "%/rubocop.yml", file_name
      git "add", ".rubocop.yml"
      commit(msg: "Add RuboCop Config")
    end.to change { total_commits }.by(1)
    file_name
  end

  def add_valid_file
    file_name = random_file_name
    expect do
      copy "%/valid.rb", file_name
      git "add", file_name
      commit(msg: "Add Valid Ruby File")
    end.to change { total_commits }.by(1)
    file_name
  end

  def checkout(branch)
    git("checkout", branch.to_s)
  end

  def total_commits
    cmd("git rev-list --all --count").first.to_i
  end

  # def dump!
  #   log_items(git("ls-files"), title: "Changed files")
  #   git("-c", "color.status=always", "status").dump!
  #   cmd("git diff --color | diff-so-fancy").dump!
  # end

  def upstream(branch)
    cmd "git branch --set-upstream-to origin/#{branch}"
  end

  def git(*args)
    Rfix::Git.git(*args)
  end

  def add_file_and_commit(file: "file.rb", branch: nil, **args)
    checkout(branch) if branch
    add_file(file: file, **args)
    cmd "git add #{file}"
    commit
  end

  def commit(msg: "A Commit Message")
    cmd 'git config user.email "you@example.com"'
    cmd 'git config user.name "Your Name"'
    cmd "git", "commit", "--author", "John Doe <john@doe.org>", "-m", msg
  end

  def ref_for_branch(branch: "test")
    "origin/#{branch}"
  end

  def add_file(file: "file.rb", content: '"hello"')
    File.write(file, content)
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

  def dirty?
    !cmd_succeeded?("git diff --quiet")
  end

  def default_cmd(cmd, dry: true, untracked: false, help: false, debug: false)
    cmd = cmd.dup
    cmd << " --dry" if dry
    cmd << " --untracked" if untracked
    cmd << " --help" if help
    cmd << " --debug" if debug
    cmd << " --no-color"
    cmd << " --list-files"
    cmd << " --config #{config_path}"

    run_command_and_stop("rfix #{cmd}", fail_on_error: false)
  end
end

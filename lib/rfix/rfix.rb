# frozen_string_literal: true

require "rubocop"
require "optparse"
require "rbconfig"
require "rfix/git_file"
require "rfix/git_helper"
require "rfix/log"
require "rfix/tracked_file"
require "rfix/untracked_file"

module Rfix
  include GitHelper
  include Log

  def thanks
    tx = []
    tx << "\n{{v}} Thank you for installing {{green:rfix v#{Rfix::VERSION}}}!\n"
    tx << "{{i}} Run {{command:rfix}} for avalible commands or any of the following to get started:"
    tx << ""
    # tx << "Here are a few examples that might be useful:"
    indent = " " * 3
    tx << "#{indent}{{command:rfix local}}   {{italic:# Auto-fixes commits not yet pushed to upstream}}"
    tx << "#{indent}{{command:rfix origin}}  {{italic:# Auto-fixes commits between HEAD and origin branch}}"
    tx << "#{indent}{{command:rfix lint}}    {{italic:# Lints commits and untracked files not yet pushed to upstream}}"
    tx << ""
    tx << "{{*}} {{bold:ProTip:}} Append {{command:--dry}} to run {{command:rfix}} in read-only mode"
    tx << ""
    tx << "{{i}} {{bold:Issues}} {{italic:https://github.com/oleander/rfix-rb/issues}}"
    tx << "{{i}} {{bold:Readme}} {{italic:https://github.com/oleander/rfix-rb/blob/master/README.md}}"
    tx << "{{i}} {{bold:Travis}} {{italic:https://travis-ci.org/github/oleander/rfix-rb}}"
    tx << ""
    tx << "{{italic:~ Made with <3 by Linus}}\n\n"
    CLI::UI.fmt(tx.join("\n"), enable_color: true)
  end

  def help
    cmds = []
    cmds << "\t{{bold:rfix [cmd] [options]}} -- {{italic:--dry --help --list-files --limit-files --config --untracked}}"
    cmds << "\t{{bold:rfix branch <branch>}} -- {{italic:Fix changes made between HEAD and <branch>}}"
    cmds << "\t{{bold:rfix origin}}          -- {{italic:Fix changes made between HEAD and origin branch}}"
    cmds << "\t{{bold:rfix local}}           -- {{italic:Fix changes not yet pushed to upstream branch}}"
    cmds << "\t{{bold:rfix info}}            -- {{italic:Display runtime dependencies and their versions}}"
    cmds << "\t{{bold:rfix all}}             -- {{italic:Fix all files in this repository}} {{warning:(not recommended)}}"
    cmds << "\t{{bold:rfix lint}}            -- {{italic:Shortcut for 'local --dry --untracked'}}"
    CLI::UI.fmt(cmds.join("\n"), enable_color: true)
  end

  def config
    @config
  end

  def set_fail_level(lint)
    if if lint
       else
         @config[:fail_level] = :warning
      end
    end
  end

  def no_auto_correct!
    @config[:auto_correct] = false
  end

  def load_config
    yield
  rescue RuboCop::Error => e
    say_abort "[Config] #{e}"
  rescue TypeError => e
    say_abort "[Config] #{e}"
  end

  def lint_mode!
    @config[:auto_correct] = false
    @config[:fail_level] = :warning if old?
    load_untracked!
  end

  def git_version
    cmd("git --version").last.split(/\s+/, 3).last
  end

  def ruby_version
    RbConfig::CONFIG["ruby_version"] || "<unknown>"
  end

  def current_os
    RbConfig::CONFIG["host_os"] || "<unknown>"
  end

  def global_enable!
    @global_enable = true
  end

  def global_enable?
    @global_enable
  end

  def init!
    @files ||= {}
    @global_enable = false
    @config = {
      color: true,
      force_exclusion: true,
      auto_correct: true,
      formatters: ["Rfix::Formatter"]
    }

    @config[:fail_level] = :autocorrect if old?
  end

  def files
    @files.values
  end

  def spin
    @spin ||= CLI::UI::SpinGroup.new
  end

  def paths
    @files.keys
  end

  def root_dir
    @root_dir ||= git("rev-parse", "--show-toplevel").first
  end

  def refresh!(source)
    @files[source.file_path]&.refresh!
  end

  def enabled?(path, line)
    return true if global_enable?

    @files[path]&.include?(line)
  end

  def to_relative(path:)
    Pathname.new(path).relative_path_from(Pathname.new(root_dir)).to_s
  rescue ArgumentError
    path
  end

  def load_untracked!
    cached(list_untrack_files.map do |path|
      UntrackedFile.new(path, nil, root_dir)
    end.select(&:file?).to_set)
  end

  def load_tracked!(reference)
    cached(git("log", "--name-only", "--pretty=format:", *params, "#{reference}..HEAD").map do |path|
      TrackedFile.new(path, reference, root_dir)
    end.select(&:file?).to_set)
  end

  def has_branch?(name)
    Open3.capture2e("git", "cat-file", "-t", name).last.success?
  end

  # Ref since last push
  def ref_since_push
    git("rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}") do
      [ref_since_origin]
    end.first
  end

  # Original branch, usually master
  def ref_since_origin
    git("show-branch", "--merge-base").first
  end

  private

  def old?
    # For version 0.80.x .. 0.83.x:
    # Otherwise it will exit with status code = 1
    (0.80..0.83).include?(RuboCop::Version::STRING.to_f)
  end

  def get_file(path, &block)
    if file = @files[path]
      block.call(file)
    end
  end

  def list_untrack_files
    git("status", "-u", "--porcelain", "--no-column").map do |line|
      line.split(" ", 2).map(&:strip)
    end.select { |el| el.first == "??" }.map(&:last)
  end

  def cached(files)
    @files ||= {}
    files.each do |file|
      @files[file.path] = file
    end
  end
end

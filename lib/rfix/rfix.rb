# frozen_string_literal: true

# rubocop:disable Layout/LineLength

require "rubocop"
require "optparse"
require "rbconfig"
require "rfix/git_file"
require "rfix/git_helper"
require "rfix/log"
require "rfix/tracked_file"
require "rfix/untracked_file"
require "git"
require "rugged"
require "rfix/repository"

module Rfix
  include GitHelper
  include Log

  def init!
    @global_enable = false
    @debug = false
    @config = {
      force_exclusion: true,
      formatters: ["Rfix::Formatter"]
    }

    @store = RuboCop::ConfigStore.new
    @repo = Repository.new(@root || Dir.pwd)
    auto_correct!
  end

  def set_main_branch(branch)
    @repo.set_main_branch(branch)
  end

  def set_root(root)
    @root = root
  end

  def no_debug!
    @debug = false
  end

  def indent
    " " * 2
  end

  def thanks
    tx = []
    tx << "\n{{v}} Thank you for installing {{green:rfix v#{Rfix::VERSION}}}!\n"
    tx << "{{i}} Run {{command:rfix}} for avalible commands or any of the following to get started:"
    tx << ""
    # tx << "Here are a few examples that might be useful:"
    tx << "#{indent}{{command:$ rfix local}}   {{italic:# Auto-fixes commits not yet pushed to upstream}}"
    tx << "#{indent}{{command:$ rfix origin}}  {{italic:# Auto-fixes commits between HEAD and origin branch}}"
    tx << "#{indent}{{command:$ rfix lint}}    {{italic:# Lints commits and untracked files not yet pushed to upstream}}"
    tx << ""
    tx << "{{*}} {{bold:ProTip:}} Append {{command:--dry}} to run {{command:rfix}} in read-only mode"
    tx << ""
    tx << "{{i}} {{bold:Issues}} {{italic:https://github.com/oleander/rfix-rb/issues}}"
    tx << "{{i}} {{bold:Readme}} {{italic:https://github.com/oleander/rfix-rb/blob/master/README.md}}"
    tx << "{{i}} {{bold:Travis}} {{italic:https://travis-ci.org/github/oleander/rfix-rb}}"
    tx << ""
    tx << "{{italic:~ Linus}}\n\n"
    CLI::UI.fmt(tx.join("\n"), enable_color: true)
  end

  def help
    cmds = [""]
    cmds << "#{indent}{{command:$ rfix [cmd] [options]}} # {{italic:--dry --help --list-files --limit-files --config --untracked}}"
    cmds << "#{indent}{{command:$ rfix branch <branch>}} #  {{italic:Fix changes made between HEAD and <branch>}}"
    cmds << "#{indent}{{command:$ rfix origin}}          #  {{italic:Fix changes made between HEAD and origin branch}}"
    cmds << "#{indent}{{command:$ rfix local}}           #  {{italic:Fix changes not yet pushed to upstream branch}}"
    cmds << "#{indent}{{command:$ rfix info}}            #  {{italic:Display runtime dependencies and their versions}}"
    cmds << "#{indent}{{command:$ rfix all}}             #  {{italic:Fix all files in this repository}} {{warning:(not recommended)}}"
    cmds << "#{indent}{{command:$ rfix lint}}            #  {{italic:Shortcut for 'local --dry --untracked'}}"
    CLI::UI.fmt(cmds.join("\n"), enable_color: true)
  end

  def repo
    @repo
  end

  def files
    @repo.files
  end

  def current_branch
    @repo.current_branch
  end

  def load_untracked!
    @repo.load_untracked!
  end

  def paths
    @repo.paths
  end

  def possible_parents
    @repo.local_branches
  end

  def load_tracked!(reference)
    @repo.load_tracked!(reference)
  end

  def debug?
    @debug
  end

  def debug!
    @config ||= {}
    @debug = true
    @config[:debug] = true
  end

  def number_of_commits_since
    cmd("git rev-list master..HEAD | wc -l").first
  end

  def config
    @config
  end

  def no_auto_correct!
    @config[:auto_correct] = false
  end

  def auto_correct!
    @config[:auto_correct] = true
  end

  def load_config
    yield @store
  rescue RuboCop::Error => e
    say_abort "[Config:RuboCop] #{e}"
  rescue TypeError => e
    say_abort "[Config:Type] #{e}"
  rescue Psych::SyntaxError => e
    say_abort "[Config:Syntax] #{e}"
  end

  def lint_mode!
    no_auto_correct!
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

  def store
    @store
  end

  def clear_cache!
    RuboCop::ResultCache.cleanup(@store, true)
  end

  def root_dir
    @repo.git_path
  end

  def refresh!(source)
    files[source.file_path]&.refresh!
  end

  def enabled?(path, line)
    return true if global_enable?
    files[path]&.include?(line)
  end

  def to_relative(path:)
    Pathname.new(path).relative_path_from(Pathname.new(root_dir)).to_s
  rescue ArgumentError
    path
  end

  def has_branch?(name)
    repo.has_reference?(name)
  end

  # Ref since last push
  # TODO: Should be a constant
  def ref_since_push
    "@{upstream}"
  end

  # Original branch, usually master
  def ref_since_origin
    if main_branch = @repo.main_branch
      return main_branch
    end

    setup_origin_branch
    ref_since_origin
  end

  def setup_origin_branch
    CLI::UI::Prompt.ask("Which one is your main branch?") do |handler|
      @repo.local_branches.each do |branch|
        handler.option(branch) do
          set_main_branch(branch)
        end
      end
    end
  end
end

# rubocop:enable Layout/LineLength

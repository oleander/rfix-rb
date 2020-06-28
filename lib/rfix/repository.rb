require "rugged"
require "rfix/file"
require "rfix/file_cache"
require "rfix/untracked"
require "rfix/tracked"

class Rfix::Repository
  include Rfix::Log
  attr_reader :files, :repo
  MAIN_BRANCH = "rfix.main"

  def initialize(root_path:, load_untracked: false, load_tracked_since: nil)
    unless File.exist?(root_path)
      raise Rfix::Error, "#{root_path} does not exist"
    end

    @files = FileCache.new(root_path)
    @repo  = Rugged::Repository.discover(root_path)
    load!(from: load_tracked_since, untracked: load_untracked)
  end

  def self.main_branch(for_path:)
    Rugged::Repository.new(for_path).config[MAIN_BRANCH]
  end

  def self.set_main_branch(for_path:, branch:)
    Rugged::Repository.new(for_path).config[MAIN_BRANCH] = branch
  end

  def refresh!(path)
    @files.get(path).refresh!
  end

  def include?(path, line)
    if file = @files.get(path)
      return file.include?(line)
    end

    true
  end

  def set_root(_path_path)
    using_path(root_path)
  end

  def set_main_branch(name)
    unless has_reference?(name)
      raise Rfix::Error.new("Branch {{error:#{name}}} does not exist")
    end

    repo.config[MAIN_BRANCH] = name
  end

  def main_branch
    repo.config[MAIN_BRANCH]
  end

  def paths
    files.pluck(&:absolute_path)
  end

  def current_branch
    repo.head.name
  end

  def has_reference?(reference)
    repo.rev_parse(reference)
  rescue Rugged::ReferenceError
    return false
  end

  def local_branches
    repo.branches.each_name(:local).to_a
  end

  def git_path
    repo.workdir
  end

  def head
    repo.rev_parse("HEAD")
  end

  private

  def load_tracked!(reference)
    repo.rev_parse(reference).diff(
      repo.rev_parse("HEAD"),
      recurse_untracked_dirs: true,
      include_untracked_content: true,
      context_lines: 0,
      include_ignored: false,
      include_untracked: true,
      ignore_whitespace: true,
      ignore_whitespace_change: true,
      ignore_whitespace_eol: true,
      ignore_submodules: true,
      include_unmodified: false
    ).each_delta do |delta|
      next if delta.deleted?

      path = delta.new_file.fetch(:path)

      if delta.untracked? && untracked
        store(Rfix::Untracked.new(path, repo, nil))
      else
        store(Rfix::Tracked.new(path, repo, reference))
      end
    end

  rescue Rugged::ReferenceError
    abort_box($ERROR_INFO.to_s) do
      prt "Reference {{error:#{reference}}} cannot be found in repository"
    end
  rescue Rugged::ConfigError
    abort_box($!.to_s) do
      prt "No upstream branch set for {{error:#{current_branch}}}"
    end
  rescue TypeError
    abort_box($ERROR_INFO.to_s) do
      prt "Reference {{error:#{reference}}} is not pointing to a tree or commit"
    end
  end

  def load!(from:, untracked:)
    load_tracked!(from) if from
    load_untracked!(untracked, reference: from)
  end

  # https://github.com/libgit2/rugged/blob/35102c0ca10ab87c4c4ffe2e25221d26993c069c/test/status_test.rb
  def load_untracked!(untracked, reference:)
    repo.status do |path, status|
      if status.include?(:worktree_new) && untracked
        store(Rfix::Untracked.new(path, repo, nil))
      elsif status.include?(:index_new)
        store(Rfix::Untracked.new(path, repo, nil))
      elsif status.include?(:index_modified)
        store(Rfix::Tracked.new(path, repo, reference))
      end
    end
  end

  def store(file)
    if File.exist?(file.path)
      @files.add(file)
    end
  end
end

require "rugged"
require "rfix/file"

class Rfix::Repository
  include Rfix::Log
  attr_reader :files, :repo
  MAIN_BRANCH = "rfix.main"

  class FileCache
    attr_reader :root_path
    include Rfix::Log
    def initialize(path)
      @files = Hash.new
      @paths = Hash.new
      @root_path = path
    end

    def add(file)
      @files[normalized_file_path(file)] ||= file
    end

    def get(path, &block)
      unless file = @files[normalize_path(path)]
        say_error "No file found for #{path}"
        return nil
      end

      block.call(file)
    end

    def pluck(&block)
      @files.values.map(&block)
    end

    private

    def normalized_file_path(file)
      normalize_path(file.absolute_path)
    end

    def to_abs(path)
      File.join(root_path, path)
    end

    def normalize_path(path)
      if cached = @paths[path]
        return cached
      end

      if Pathname.new(path).absolute?
        @paths[path] = File.realdirpath(path)
      else
        @paths[path] = File.realdirpath(to_abs(path))
      end
    end
  end

  def initialize(root_path, branch)
    @files  = FileCache.new(root_path)
    @git    = ::Git.open(root_path)
    @repo   = Rugged::Repository.new(root_path)
    @load_untracked = false
    set_main_branch(branch) if branch
  end

  def set_main_branch(name)
    repo.config[MAIN_BRANCH] = name
  end

  def main_branch
    repo.config[MAIN_BRANCH]
  end

  def paths
    files.pluck(&:absolute_path)
  end

  def current_branch
    git.current_branch
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
    git.dir.to_s
  end

  def head
    repo.rev_parse("HEAD")
  end

  def load_tracked!(reference)
    repo.diff(repo.rev_parse(reference), head, recurse_untracked_dirs: @load_untracked, include_untracked_content: @load_untracked, context_lines: 0, include_ignored: false, include_untracked: @load_untracked, ignore_whitespace: true, ignore_whitespace_change: true, ignore_whitespace_eol: true, ignore_submodules: true).each_delta do |delta|
      next if delta.deleted?
      store(Rfix::Tracked.new(delta.new_file.fetch(:path), repo, reference))
    end
  rescue Rugged::ReferenceError
    abort_box($!.to_s) do
      prt "Reference {{error:#{reference}}} cannot be found in repository"
    end
  rescue Rugged::ConfigError
    abort_box($!.to_s) do
      prt "No upstream branch set for {{error:#{current_branch}}}"
    end
  rescue TypeError
    abort_box($!.to_s) do
      prt "Reference {{error:#{reference}}} is not pointing to a tree or commit"
    end
  end

  def load_untracked!
    @load_untracked = true
    repo.status do |path, status|
      next unless status.include?(:worktree_new)
      store(Rfix::Untracked.new(path, repo, nil))
    end
  end

  private

  def store(file)
    @files.add(file)
  end

  def git
    @git
  end
end

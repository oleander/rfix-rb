require "rugged"
require "rfix/file"

class Rfix::Repository
  include Rfix::Log
  attr_reader :files, :repo
  MAIN_BRANCH = "rfix.main"

  class FileCache
    attr_reader :root_path
    def initialize(path)
      @files = Hash.new
      @paths = Hash.new
      @root_path = path
    end

    def add(file)
      @files[normalized_file_path(file)] = file
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

  def initialize(root_path)
    @files  = FileCache.new(root_path)
    @git    = ::Git.open(root_path)
    @repo   = Rugged::Repository.new(root_path)
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

  def load_tracked!(reference)
    repo.diff(reference, "HEAD").each_delta do |delta|
      next if delta.deleted?
      store(Rfix::Tracked.new(delta.new_file.fetch(:path), repo, reference))
    end
  rescue Rugged::ReferenceError
    say_abort "Reference {{error:#{reference}}} cannot be found in repository"
  rescue Rugged::ConfigError
    abort_box($!.to_s) do
      prt "No upstream branch set for {{error:#{current_branch}}}"
    end
  end

  def load_untracked!
    repo.status do |path, status|
      next if status.include?(:ignored)
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

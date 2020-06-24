require "rugged"
require "rfix/file"

class Rfix::Repository
  include Rfix::Log
  attr_reader :files, :repo
  MAIN_BRANCH = "rfix.main"

  def initialize(root_path)
    @files  = Hash.new
    @git    = ::Git.open(root_path)
    @repo   = Rugged::Repository.new(root_path)
  end

  def set_main_branch(name)
    @rugged.config[MAIN_BRANCH] = name
  end

  def main_branch
    @rugged.config[MAIN_BRANCH]
  end

  def paths
    files.keys
  end

  def current_branch
    git.current_branch
  end

  def local_branches
    @rugged.branches.each_name(:local).to_a
  end

  def git_path
    git.dir.to_s
  end

  def load_tracked!(reference)
    repo.diff(reference, "HEAD").each_delta.to_a.each do |delta|
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
    @files[file.path] = file
  end

  def git
    @git
  end
end

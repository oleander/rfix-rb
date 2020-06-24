require "rugged"
require "rfix/file"

class Rfix::Repository
  include Rfix::Log
  attr_reader :files
  MAIN_BRANCH = "rfix.main"

  def initialize(root_path)
    @files  = {}
    @git    = ::Git.open(root_path)
    @rugged = Rugged::Repository.new(root_path)
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
    cache do
      @rugged.diff(reference, "HEAD").each_delta.to_a.map do |delta|
        Rfix::Tracked.new(delta.new_file.fetch(:path), @rugged, reference)
      end
    end
  rescue Rugged::ReferenceError
    say_abort "Reference {{error:#{reference}}} cannot be found in repository"
  rescue Rugged::ConfigError
    abort_box($!.to_s) do
      prt "No upstream branch set for {{error:#{current_branch}}}"
    end
  end

  def load_untracked!
    cache do
      git.status.untracked.keys.map do |file|
        Rfix::Untracked.new(file, @repo, nil)
      end
    end
  end

  private

  def cache
    yield.each do |file|
      @files[file.path] = file
    end
  end

  def git
    @git
  end
end

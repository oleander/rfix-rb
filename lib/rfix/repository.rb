require "rugged"

class Rfix::Repository
  include Rfix::Log
  attr_reader :files

  def initialize(root_path)
    @git = ::Git.open(root_path)#, log: Logger.new($stdout))
    @files = {}
    @rugged = Rugged::Repository.new(root_path)
  end

  def paths
    files.keys
  end

  def current_branch
    git.current_branch
  end

  def possible_parents
    git.branches.local.reject { |branch| branch == @git.branch }
  end

  def git_path
    git.dir.to_s
  end

  def load_tracked!(reference)
    cache do
      git.diff(reference).map do |file|
        Rfix::AFile.new(file, @repo, reference)
      end
    end
  end

  def load_untracked!
    cache do
      git.status.untracked.keys.map do |file|
        Rfix::AFile.new(file, @repo, nil)
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

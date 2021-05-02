# frozen_string_literal: true

require "rfix/rake/paths"
require "fileutils"
require "pathname"
require "faker"

SetupGit = Struct.new(:root_path, :id) do
  include Rfix::Log

  def self.setup!
    root_path = Pathname(__dir__).join("../../")

    tmp_dir     = root_path.join("tmp").tap do |path|
      FileUtils.mkdir_p(path.to_s)
    end

    id          = Faker::Code.asin
    root_path   = Dir.mktmpdir(id, tmp_dir)
    new(root_path, id)
  end

  def teardown!
    rm root_path
  end

  def clone!
    return reset! if @git

    Dir.chdir root_path do
      @git = Git.clone(Bundle::Simple::FILE, "repo", path: root_path)
    end
    @git.checkout(Bundle::TAG)
  end

  def git
    check_clone_status!; @git
  end

  def git_path
    git.dir.to_s
  end

  def msg
    Faker::Hacker.say_something_smart
  end

  def reset!
    check_clone_status!
    git.clean(force: true, d: true)
    git.reset_hard(Bundle::TAG)
    git.checkout("master")
    check_cleanliness!
  end

  private

  def check_cleanliness!
    if git.status.dirty?
      say_abort "Could not reset #{git_path}, still dirty: #{git.status.number_of_dirty_files}"
    end
  end

  def check_clone_status!
    raise "Run clone first!" unless @git
  end

  def rm(path)
    unless Pathname.new(path).absolute?
      say_abort "Path is not an absolute path #{path}"
    end

    unless path.include?(id)
      say_abort "Path #{path} does not include id #{id}"
    end

    FileUtils.remove_dir(path, force: true)
  end
end

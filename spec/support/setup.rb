require "pathname"

class SetupGit < Struct.new(:bundle_file, :root_path, :id)
  include Rfix::Log

  RALLY_POINT = RP = "rally-point"

  def self.setup!
    tmp_dir     = File.join(__dir__, "../../tmp")
    id          = Faker::Code.asin
    root_path   = Dir.mktmpdir(id, tmp_dir)
    src_path    = File.join(root_path, "src")
    bundle_file = File.join(root_path, "git.bundle")
    git         = Git.init(src_path)

    git.chdir do
      Rfix::Log.say("Write ignore file")
      File.write(".gitignore", "# Empty")

      git.add(".gitignore")
      git.commit("Add empty .gitignore")
      git.add_tag(RALLY_POINT)

      cmd "git", "bundle", "create", bundle_file, "--all"
    end

    new(bundle_file, root_path, id)
  end

  def self.cmd(*args)
    out, status = Open3.capture2(*args)
    abort out unless status.success?
  end

  def teardown!
    rm(root_path)
  end

  def clone!
    @git = Git.clone(bundle_file, "repo", path: root_path)
    @git.branch("master").checkout
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
    # Remove untracked files and dirs
    git.clean(force: true, f: true, d: true)

    # Undo all stages
    git.reset_hard

    # Reset to init commit
    git.checkout(RALLY_POINT)
    git.checkout("master")

    check_cleanliness!
  end

  private

  def check_cleanliness!
    if git.status.dirty?
      say_abort "Could not reset #{git_path}, still dirty"
    end
  end

  def check_clone_status!
    say_abort "Run clone first!" unless @git
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

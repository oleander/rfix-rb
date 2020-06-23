require "pathname"

class SetupGit < Struct.new(:bundle_file, :root_path)
  include Rfix::Log

  RALLY_POINT = RP = "rally-point"

  def self.setup!(root_path: Dir.mktmpdir)
    src_path    = File.join(root_path, "src")
    bundle_file = File.join(root_path, "git.bundle")
    git         = Git.init(src_path)

    git.chdir do
      Rfix::Log.say("Write ignore file")
      File.write(".gitignore", "# Empty")

      git.add(".gitignore")
      git.commit("Add empty .gitignore")

      cmd "git", "bundle", "create", bundle_file, "--all"
    end

    new(bundle_file, root_path)
  end

  def self.cmd(*args)
    out, status = Open3.capture2(*args)
    abort out unless status.success?
  end


  def teardown!
    rm(root_path)
  end

  def clone!
    git_path = File.join("git", root_path)
    @git = Git.clone(bundle_file, "base", path: git_path, log: Logger.new($stderr))
    @git.add_tag(RALLY_POINT)
    @git
  end

  def git
    check_clone_status!; @git
  end

  def git_path
    git.dir.to_s
  end

  def reset!
    check_clone_status!
    git.clean(force: true, d: true)
    git.reset_hard(RALLY_POINT)
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

    FileUtils.remove_dir(path, force: true)
  end
end

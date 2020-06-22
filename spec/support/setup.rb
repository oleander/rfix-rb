class SetupGit < Struct.new(:bundle_file, :bundle_path)
  def self.setup
    tmp_path = File.expand_path(File.join(__dir__, "../../tmp"))

    Dir.mktmpdir("src", tmp_path) do |src_path|
      bundle_path = Dir.mktmpdir("bundle", tmp_path)
      bundle_file = File.join(bundle_path, "git.bundle")
      git         = Git.init(src_path)

      git.chdir do
        Rfix::Log.say("Write ignore file")
        File.write(".gitignore", "")
      end

      git.add(".gitignore")
      git.commit("A Commit Message")

      Rfix::Log.say "Write to bundle path #{git.repo}"
      Rfix::Git.git("bundle", "create", bundle_file, "--all", root: src_path)

      new(bundle_file, bundle_path)
    end
  end

  def teardown
    FileUtils.remove_dir(bundle_path, force: true)
  end
end

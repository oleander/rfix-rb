RSpec.describe "the setup command", type: :aruba do
  before { checkout("master") }

  describe "branch" do
    it "defaults to asking the user for their default branch" do
      run_command("rfix setup --main-branch master")
      expect(all_stdout).to match(/master/)
    end

    it "fails if the branch provided doesn't exist" do
      run_command("rfix setup --main-branch nope")
      is_expected.to have_exit_status(1)
      expect(all_stdout).to match(/nope/)
    end

    it "fails if the branch provided doesn't exist" do
      run_command("rfix setup", exit_timeout: 2)
      is_expected.to have_exit_status(15)
    end
  end

  describe "root" do
    it "fails when the root path is invalid" do
      run_command("rfix setup --main-branch master --root tmp/")
      is_expected.to have_exit_status(1)
    end

    it "succeedes when the root path is valid" do
      Dir.mktmpdir do |repo|
        cmd "git", "clone", Bundle::Simple::FILE, repo
        cd(repo) do
          cmd "git", "checkout", "master"
          run_command("rfix setup --main-branch master --root #{repo}")
        end
        is_expected.to have_exit_status(0)
      end
    end
  end
end

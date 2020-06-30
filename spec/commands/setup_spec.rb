RSpec.describe "the setup command", :git, checkout: "master" do
  describe "branch" do
    it "defaults to asking the user for their default branch", :success do
      run_command("rfix setup --main-branch master")
      expect(all_output).to match(/master/)
    end

    it "fails if the branch provided doesn't exist", :failure do
      run_command("rfix setup --main-branch nope")
    end

    it "fails if the branch provided doesn't exist" do
      run_command("rfix setup", exit_timeout: 2)
      is_expected.to have_exit_status(15)
    end
  end
end

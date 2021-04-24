RSpec.shared_examples "a command that accepts files" do
  describe "successful passing files", :git, checkout: "stable", upstream: "master" do
    it "only effects those files that are passed in" do
      file1 = f(:invalid).tracked.write!
      file2 = f(:invalid).tracked.write!

      run_command_and_stop("rfix #{command} --root #{repo_path} --config #{config_path} --format json --main-branch master #{file1.to_path}")

      expect(subject).to have_fixed(file1)
      expect(subject).not_to have_fixed(file2)
      expect(subject).not_to have_linted(file2)
    end
  end
end

# frozen_string_literal: true

RSpec.describe "lint command" do
  describe "preload", cmd: "lint", checkout: "stable" do
    it_behaves_like "a lint command"
    it_behaves_like "a destroyed file"
  end

  describe "successful passing files", :git, checkout: "stable" do
    it "only effects those files that are passed in" do
      file1 = f(:invalid).tracked.write!
      file2 = f(:invalid).tracked.write!

      run_command_and_stop("rfix lint --format json --root #{repo_path} --test --config #{config_path} --main-branch master #{file1.to_path}", fail_on_error: false)

      expect(subject).to have_linted(file1)
      expect(subject).not_to have_fixed(file1)
      expect(subject).not_to have_fixed(file2)
      expect(subject).not_to have_linted(file2)
    end
  end
end

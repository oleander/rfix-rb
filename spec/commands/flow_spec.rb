RSpec.describe "flow", :git, checkout: "stable" do
  let(:branch) { "hello-world" }

  # it "handles a flow" do
  #   file0 = f(:invalid).tracked.write!
  #   git.branch("okoko").checkout
  #   file1 = f(:invalid).tracked.write!
  #   git.branch(branch).checkout
  #   file2 = f(:invalid).tracked.write!
  #
  #   run_command_and_stop("rfix branch #{branch} --untracked --format json --root #{repo_path} --test --config #{config_path} --main-branch master", fail_on_error: false)
  #
  #   is_expected.to have_offenses_for(file2)
  #   is_expected.to have_fixed_staged_file(file2)
  #
  #   is_expected.not_to have_offenses_for(file0)
  #   is_expected.not_to have_fixed_staged_file(file0)
  #
  #   is_expected.not_to have_offenses_for(file1)
  #   is_expected.not_to have_fixed_staged_file(file1)
  # end
end

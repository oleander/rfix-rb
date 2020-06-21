RSpec.describe Rfix, type: :aruba do
  subject { all_output }
  describe "autofix" do
    it "works" do
      # local_cmd
      # add_file_and_commit
      # branch_cmd("HEAD~1", dry: false)
      # expect(all_output).to include("4 offenses detected")
      # expect(all_output).to include("4 offenses corrected")
      # expect(last_command_started).to have_exit_status(0)
      # expect(no_changed_files).to eq(1)
      # copy "%/fixtures/rubocop.yml", ".rubocop.yml"
      # copy "%/rubocop-line-length-5.yml", ".rubocop-line-length-5.yml"
      # git("add .rubocop*.yml")
      # git("commit", "--amend", "-m", "Add RuboCop configuration files")
    end
  end
end

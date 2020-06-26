RSpec.describe "lint", type: :aruba do
  let(:rubocop_help_arg) { ["--parallel"] }

  describe "read-only" do
    before { add_file_and_commit }
    it "does not alter files" do
      expect { lint_cmd }.not_to change { no_changed_files }
    end
  end

  describe "automated" do
    describe "exit code 0", :lint do
      describe "no files" do
        let(:file1) { tracked :invalid }
        let(:file2) { untracked :invalid }
        it { is_expected.to have_exit_status(1) }
        it { is_expected.to list_file(file1) }
        it { is_expected.to_not list_file(file2) }
      end
    end

    describe "exit code 1" do
      describe "commited files with offenses" do
        before { add_file_and_commit; lint_cmd }
        it { is_expected.to have_exit_status(1) }
      end

      describe "uncommited files with offenses" do
        it "includes untracked files" do
          filename = "my_file.rb"
          add_file(file: filename)
          lint_cmd
          expect(all_output).to match(/#{filename}/)
          expect(last_command_started).to have_exit_status(1)
        end
      end
    end
  end

  # describe "files with no offenses" do
  #   before { lint_cmd }
  #   subject { last_command_started }
  #   # it { is_expected.to have_output(/no files/i) }
  #   it { is_expected.to have_exit_status(0) }
  #
  #   it "does not alter files" do
  #     expect { lint_cmd }.to_not change { no_changed_files }
  #   end
  #
  #   it "exists with status code 0" do
  #     expect(last_command_started).to have_exit_status(0)
  #   end
  # end
end

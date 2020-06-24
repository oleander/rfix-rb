RSpec.describe Rfix, type: :aruba do
  let(:rubocop_help_arg) { ["--parallel"] }

  subject { all_output }

  describe "no files and no changes" do
    describe "local" do
      before { local_cmd }
      subject { all_output }
      it { is_expected.to include("No files") }
    end

    describe "origin" do
      before { origin_cmd }
      subject { all_output }
      it { is_expected.to include("No files") }
    end

    describe "branch" do
      before { branch_cmd }
      subject { all_output }
      it { is_expected.to include("No files") }
    end
  end

  describe "no upstream for local" do
    before do
      setup_test_branch
      local_cmd
    end

    it { is_expected.to_not include("no upstream") }
    xit { is_expected.to include(ref_for_branch) }
  end

  describe "info" do
    before { default_cmd("info") }
    subject { last_command_started }

    %w[Rfix RuboCop OS Git Ruby].each do |param|
      it { is_expected.to have_output(/#{param}/) }
    end

    it { is_expected.to have_exit_status(0) }
  end

  describe "--untrackeed" do
    let(:filename) { "my-file.rb" }

    before do
      setup_test_branch(upstream: :master)
      add_file(file: filename)
    end

    describe "with" do
      describe "branch" do
        before { branch_cmd(untracked: true) }
        it { is_expected.to include(filename) }
      end

      describe "local" do
        before { local_cmd(untracked: true) }
        it { is_expected.to include(filename) }
      end

      describe "origin" do
        before { origin_cmd(untracked: true) }
        it { is_expected.to include(filename) }
      end
    end

    describe "without" do
      describe "branch" do
        before { branch_cmd(untracked: false) }
        it { is_expected.not_to include(filename) }
      end

      describe "local" do
        before { local_cmd(untracked: false) }
        it { is_expected.not_to include(filename) }
      end

      describe "origin" do
        before { origin_cmd(untracked: false) }
        it { is_expected.not_to include(filename) }
      end
    end
  end

  describe "--dry" do
    before do
      setup_test_branch(upstream: :master)
    end

    describe "all" do
      describe "with" do
        it "does not alter files" do
          expect { default_cmd("all", dry: true) }.to change { no_changed_files }.by(0)
        end
      end

      describe "without" do
        it "does alter files" do
          expect { default_cmd("all", dry: false) }.to change { no_changed_files }.by(19)
        end
      end
    end

    describe "branch" do
      it "makes no change when used" do
        expect { branch_cmd(dry: true) }.to_not change { no_changed_files }
      end

      it "makes change when left out" do
        expect { branch_cmd(dry: false); }.to change { no_changed_files }.by(6)
      end
    end

    describe "local" do
      before { add_file_and_commit(branch: "master") }

      it "makes no change when used" do
        expect { local_cmd(dry: true) }.to_not change { no_changed_files }
      end

      it "makes change when left out" do
        expect { local_cmd(dry: false) }.to change { no_changed_files }.by(1)
      end
    end

    describe "origin" do
      it "makes no change when used" do
        expect { origin_cmd(dry: true) }.to_not change { no_changed_files }
      end

      it "makes change when left out" do
        expect { origin_cmd(dry: false) }.to change { no_changed_files }.by(6)
      end
    end
  end

  describe "--help" do
    describe "with" do
      before { default_cmd("", help: true) }
      it { is_expected.to include(*rubocop_help_arg) }
    end

    describe "without" do
      before { default_cmd("", help: false) }
      it { is_expected.not_to include(*rubocop_help_arg) }
    end
  end

  describe "fixed" do
    before do
      setup_test_branch(upstream: :test)
    end

    describe "origin" do
      before { origin_cmd }
      it { is_expected.to include("8 files") }
    end

    describe "local" do
      before { local_cmd }
      it { is_expected.to include("No files") }
    end

    describe "branch" do
      before { branch_cmd }
      it { is_expected.to include("8 files") }
    end
  end

  describe "local" do
    before do
      setup_test_branch(upstream: :test)
      add_file_and_commit(file: "file.rb")
    end

    it "local" do
      expect(all_output).not_to include("file.rb")
      local_cmd
      expect(all_output).to include("1 files")
      expect(all_output).to include("file.rb")
    end
  end

  describe "status codes" do
    describe "has files" do
      before { setup_test_branch(upstream: :master) }
      subject { last_command_started }

      describe "branch" do
        before { branch_cmd }
        it { is_expected.to have_exit_status(1) }
      end

      describe "origin" do
        before { origin_cmd }
        it { is_expected.to have_exit_status(1) }
      end

      describe "local" do
        it "handles new files" do
          checkout("test")
          upstream("test")
          add_file_and_commit(file: "file.rb")
          local_cmd
          expect(all_output).to include("1 files")
          expect(last_command_started).to have_exit_status(1)
        end
      end
    end

    describe "no files" do
      describe "branch" do
        before { branch_cmd }
        subject { last_command_started }
        it { is_expected.to have_output(/no files/i) }
        it { is_expected.to have_exit_status(0) }
      end

      describe "local" do
        before { local_cmd }
        subject { last_command_started }
        it { is_expected.to have_output(/no files/i) }
        it { is_expected.to have_exit_status(0) }
      end

      describe "local" do
        before { origin_cmd }
        subject { last_command_started }
        it { is_expected.to have_output(/no files/i) }
        it { is_expected.to have_exit_status(0) }
      end
    end
  end

  describe "fails" do
    it "displays help when no command is given" do
      expect { default_cmd("") }.to_not change { no_changed_files }
      expect(all_output).to include("Valid rfix")
      expect(last_command_started).to have_exit_status(1)
    end

    it "displays help when an invalid command is given" do
      expect { default_cmd("not-a-command") }.to_not change { no_changed_files }
      expect(all_output).to include("Valid rfix")
      expect(last_command_started).to have_exit_status(1)
    end

    it "displays help even when an invalid command is given" do
      expect { default_cmd("not-a-command", help: true) }.to_not change { no_changed_files }
      expect(all_output).to_not include("Valid rfix")
      expect(all_output).to include(*rubocop_help_arg)
      expect(last_command_started).to have_exit_status(0)
    end
  end

  describe "change" do
    before do
      setup_test_branch(upstream: :master)
    end

    it "defaults to zero" do
      expect(no_changed_files).to eq(0)
    end

    describe "run" do
      describe "with" do
        it "origin" do
          expect { origin_cmd(dry: false) }.to change { no_changed_files }.by(6)
          expect(all_output).to include("30 offenses corrected")
          expect(all_output).to include("30 offenses detected")
          expect(last_command_started).to have_exit_status(0)
        end

        it "local" do
          checkout("test")
          upstream("test")
          expect { local_cmd(dry: false) }.to change { no_changed_files }.by(0)
          add_file_and_commit # Add a file
          expect { local_cmd(dry: false) }.to change { no_changed_files }.by(1)
          expect(all_output).to include("4 offenses detected")
          expect(all_output).to include("4 offenses corrected")
          expect(last_command_started).to have_exit_status(0)
        end

        it "branch" do
          expect { branch_cmd(dry: false) }.to change { no_changed_files }.by(6)
          expect(all_output).to include("30 offenses detected")
          expect(all_output).to include("30 offenses corrected")
          expect(last_command_started).to have_exit_status(0)
        end
      end

      describe "without" do
        it "origin" do
          expect { origin_cmd(dry: true) }.to_not change { no_changed_files }
          expect(all_output).not_to include("corrected")
          expect(last_command_started).to have_exit_status(1)
        end

        it "local" do
          expect { local_cmd(dry: true) }.to_not change { no_changed_files }
          add_file_and_commit
          expect { local_cmd(dry: true) }.to_not change { no_changed_files }
          expect(all_output).not_to include("corrected")
          expect(last_command_started).to have_exit_status(1)
        end

        it "branch" do
          expect { branch_cmd(dry: true) }.to_not change { no_changed_files }
          expect(all_output).not_to include("corrected")
          expect(last_command_started).to have_exit_status(1)
        end
      end
    end
  end
end

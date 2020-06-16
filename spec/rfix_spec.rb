RSpec.describe Rfix, type: :aruba do
  include Rfix::Support
  include Aruba::Api

  let(:ignore) { ".gitignore" }
  let(:repo) { "git-fame-rb" }

  around do |example|
    copy "%/git-fame-rb", repo

    cd(repo) do
      example.run
    end
  end

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

    it { is_expected.to include("no upstream") }
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

    describe "branch" do
      it "makes no change when used" do
        expect { branch_cmd(dry: true) }.to_not change { no_changed_files }
      end

      it "makes change when left out" do
        expect { branch_cmd(dry: false) }.to change { no_changed_files }.by(4)
      end
    end

    describe "local" do
      before { add_file_and_commit }

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
        expect { origin_cmd(dry: false) }.to change { no_changed_files }.by(4)
      end
    end
  end

  describe "--help" do
    let(:rubocop_arg) { "--display-only-failed" }

    describe "with" do
      before { origin_cmd(help: true) }
      it { is_expected.to include(rubocop_arg) }
    end

    describe "without" do
      before { origin_cmd(help: false) }
      it { is_expected.not_to include(rubocop_arg) }
    end
  end

  describe "fixed" do
    before do
      setup_test_branch(upstream: :master)
    end

    describe "origin" do
      before { origin_cmd }
      it { is_expected.to include("5 files") }
    end

    describe "local" do
      before { local_cmd }
      it { is_expected.to include("No files") }
    end

    describe "branch" do
      before { branch_cmd }
      it { is_expected.to include("5 files") }
    end
  end

  describe "local" do
    before do
      setup_test_branch(upstream: :master)
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

  describe "change" do
    it "defaults to zero" do
      expect(no_changed_files).to eq(0)
    end

    describe "run" do
      before do
        setup_test_branch(upstream: :master)
      end

      describe "with" do
        it "origin" do
          origin_cmd(dry: false)
          expect(all_output).to include("22 offenses")
          expect(all_output).to include("corrected")
          expect(last_command_started).to have_exit_status(0)
          expect(no_changed_files).to eq(4)
        end

        it "local" do
          add_file_and_commit
          local_cmd(dry: false)
          expect(all_output).to include("2 offenses")
          expect(all_output).to include("corrected")
          expect(last_command_started).to have_exit_status(0)
          expect(no_changed_files).to eq(1)
        end

        it "branch" do
          branch_cmd(dry: false)
          expect(all_output).to include("22 offenses")
          expect(all_output).to include("corrected")
          expect(last_command_started).to have_exit_status(0)
          expect(no_changed_files).to eq(4)
        end
      end

      describe "without" do
        it "origin" do
          origin_cmd(dry: true)
          expect(all_output).not_to include("corrected")
          expect(last_command_started).to have_exit_status(1)
          expect(no_changed_files).to eq(0)
        end

        it "local" do
          add_file_and_commit
          local_cmd(dry: true)
          expect(all_output).not_to include("corrected")
          expect(last_command_started).to have_exit_status(1)
          expect(no_changed_files).to eq(0)
        end

        it "branch" do
          branch_cmd(dry: true)
          expect(all_output).not_to include("corrected")
          expect(last_command_started).to have_exit_status(1)
          expect(no_changed_files).to eq(0)
        end
      end
    end
  end
end

RSpec.shared_examples "a lint command", :read_only do
  describe "staged" do
    describe "staged files" do
      describe "invalid" do
        let(:file) { f(:invalid).staged }
        it { is_expected.to have_exit_status(1) }
        it { is_expected.to have_listed_staged_file(file) }
        it { is_expected.to have_linted_staged_file(file) }
      end

      describe "valid" do
        let(:file) { f(:valid).staged }
        it { is_expected.to have_exit_status(0) }
        it { is_expected.to have_listed_staged_file(file) }
        it { is_expected.not_to have_linted_staged_file(file) }
      end

      describe "unfixable" do
        let(:file) { f(:unfixable).staged }
        it { is_expected.to have_exit_status(1) }
        it { is_expected.to have_listed_staged_file(file) }
        it { is_expected.to have_linted_staged_file(file) }
      end

      describe "not ruby" do
        let(:file) { f(:not_ruby).staged }
        it { is_expected.to have_exit_status(0) }
        it { is_expected.not_to have_listed_staged_file(file) }
        it { is_expected.not_to have_linted_staged_file(file) }
      end
    end

    describe "tracked & staged" do
      describe "invalid" do
        let(:file) { f(:invalid).tracked.append.staged }
        it { is_expected.to have_exit_status(1) }
        it { is_expected.to have_listed_staged_file(file) }
        it { is_expected.to have_linted_staged_file(file) }
      end

      describe "valid" do
        let(:file) { f(:valid).tracked.append.staged }
        it { is_expected.to have_exit_status(1) }
        it { is_expected.to have_listed_staged_file(file) }
        it { is_expected.to have_linted_staged_file(file) }
      end

      describe "unfixable" do
        let(:file) { f(:unfixable).tracked.append.staged }
        it { is_expected.to have_exit_status(1) }
        it { is_expected.to have_listed_staged_file(file) }
        it { is_expected.to have_linted_staged_file(file) }
      end

      describe "not ruby" do
        let(:file) { f(:not_ruby).tracked }
        it { is_expected.to have_exit_status(0) }
        it { is_expected.not_to have_listed_staged_file(file) }
        it { is_expected.not_to have_linted_staged_file(file) }
      end
    end
  end

  describe "tracked files" do
    describe "invalid" do
      let(:file) { f(:invalid).tracked }
      it { is_expected.to have_exit_status(1) }
      it { is_expected.to have_listed_tracked_file(file) }
      it { is_expected.to have_linted_tracked_file(file) }
    end

    describe "valid" do
      let(:file) { f(:valid).tracked }
      it { is_expected.to have_exit_status(0) }
      it { is_expected.to have_listed_tracked_file(file) }
      it { is_expected.not_to have_linted_tracked_file(file) }
    end

    describe "unfixable" do
      let(:file) { f(:unfixable).tracked }
      it { is_expected.to have_exit_status(1) }
      it { is_expected.to have_listed_tracked_file(file) }
      it { is_expected.to have_linted_tracked_file(file) }
    end

    describe "not ruby" do
      let(:file) { f(:not_ruby).tracked }
      it { is_expected.to have_exit_status(0) }
      it { is_expected.not_to have_listed_tracked_file(file) }
      it { is_expected.not_to have_linted_tracked_file(file) }
    end
  end

  describe "untracked files" do
    describe "invalid" do
      let(:file) { f(:invalid).untracked }
      it { is_expected.to have_exit_status(1) }
      it { is_expected.to have_listed_tracked_file(file) }
      it { is_expected.to have_linted_tracked_file(file) }
    end

    describe "valid" do
      let(:file) { f(:valid).tracked }
      it { is_expected.to have_exit_status(0) }
      it { is_expected.to have_listed_tracked_file(file) }
      it { is_expected.not_to have_linted_tracked_file(file) }
    end

    describe "unfixable" do
      let(:file) { f(:unfixable).untracked }
      it { is_expected.to have_exit_status(1) }
      it { is_expected.to have_listed_tracked_file(file) }
      it { is_expected.to have_linted_tracked_file(file) }
    end

    describe "not ruby" do
      let(:file) { f(:not_ruby).tracked }
      it { is_expected.to have_exit_status(0) }
      it { is_expected.not_to have_listed_tracked_file(file) }
      it { is_expected.not_to have_linted_tracked_file(file) }
    end
  end

  describe "grouped files" do
    describe "untracked files mixed with tracked files" do
      let(:file1) { f(:invalid).tracked }
      let(:file2) { f(:invalid).untracked }
      let(:file3) { f(:valid).tracked }
      let(:file4) { f(:valid).tracked }

      it { is_expected.to have_exit_status(1) }
      it { is_expected.to list_file(file1) }
      it { is_expected.to have_linted(file1) }

      it { is_expected.to list_file(file2) }
      it { is_expected.to have_linted(file2) }

      it { is_expected.to list_file(file3) }
      it { is_expected.not_to have_linted(file3) }

      it { is_expected.to list_file(file4) }
      it { is_expected.not_to have_linted(file4) }
    end

    describe "tracked files" do
      let(:file1) { f(:invalid).tracked }
      let(:file2) { f(:invalid).untracked }
      let(:file3) { f(:valid).tracked }
      let(:file4) { f(:valid).tracked }

      it { is_expected.to have_exit_status(1) }

      it { is_expected.to list_file(file1) }
      it { is_expected.to have_linted(file1) }

      it { is_expected.to list_file(file2) }
      it { is_expected.to have_linted(file2) }

      it { is_expected.to list_file(file3) }
      it { is_expected.not_to have_fixed(file3) }

      it { is_expected.to list_file(file4) }
      it { is_expected.not_to have_fixed(file4) }
    end
  end
end

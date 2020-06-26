RSpec.describe "lint command", type: :aruba do
  describe "tracked files", :lint do
    let(:file1) { tracked :invalid }
    let(:file2) { untracked :invalid }
    let(:file3) { tracked :valid }
    let(:file4) { untracked :valid }

    it { is_expected.to have_exit_status(1) }
    it { is_expected.to list_file(file1) }
    it { is_expected.not_to have_fixed(file1) }

    it { is_expected.to list_file(file2) }
    it { is_expected.not_to have_fixed(file2) }

    it { is_expected.to list_file(file3) }
    it { is_expected.not_to have_fixed(file3) }

    it { is_expected.to_not list_file(file4) }
    it { is_expected.not_to have_fixed(file4) }
  end

  describe "untracked files", :lint, args: [:untracked] do
    let(:file1) { tracked :invalid }
    let(:file2) { untracked :invalid }
    let(:file3) { tracked :valid }
    let(:file4) { untracked :valid }

    it { is_expected.to have_exit_status(1) }
    it { is_expected.to list_file(file1) }
    it { is_expected.not_to have_fixed(file1) }

    it { is_expected.to list_file(file2) }
    it { is_expected.to have_fixed(file2) }

    it { is_expected.to list_file(file3) }
    it { is_expected.not_to have_fixed(file3) }

    it { is_expected.to list_file(file4) }
    it { is_expected.not_to have_fixed(file4) }
  end
end

RSpec.describe "origin:cmd", type: :aruba do
  describe "exit code 0", :origin do
    describe "no files" do
      let(:file1) { tracked :invalid }
      let(:file2) { untracked :invalid }
      it { is_expected.to list_file(file1) }
      it { is_expected.to have_fixed(file1) }

      it { is_expected.not_to list_file(file2) }
      it { is_expected.not_to have_fixed(file2) }

      xit { is_expected.to have_exit_status(1) }
    end
  end
end

RSpec.describe "local:cmd", type: :aruba do
  describe "exit code 0", :local do
    describe "no files" do
      let(:file1) { tracked :invalid }
      let(:file2) { tracked :not_ruby }
      let(:file3) { untracked :invalid }

      it { is_expected.to list_file(file1) }
      it { is_expected.to have_fixed(file1) }

      it { is_expected.to list_file(file2) }
      it { is_expected.not_to have_fixed(file2) }

      it { is_expected.not_to list_file(file3) }
      it { is_expected.not_to have_fixed(file3) }

      xit { is_expected.to have_exit_status(1) }
    end
  end
end


RSpec.describe "branch:cmd", type: :aruba do
  context "the branch command", :branch do
    describe "tracked files" do
      let(:file1) { tracked :invalid }
      let(:file2) { untracked :invalid }

      it { is_expected.to list_file(file1) }
      it { is_expected.to have_fixed(file1) }

      it { is_expected.not_to list_file(file2) }
      it { is_expected.not_to have_fixed(file2) }

      xit { is_expected.to have_exit_status(1) }
    end

    describe "untracked files", args: [:untracked] do
      let(:file1) { tracked :invalid }
      let(:file2) { untracked :invalid }

      it { is_expected.to list_file(file1) }
      it { is_expected.to have_fixed(file1) }

      it { is_expected.not_to list_file(file2) }
      it { is_expected.not_to have_fixed(file2) }

      xit { is_expected.to have_exit_status(1) }
    end
  end
end

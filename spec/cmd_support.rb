RSpec.describe Rfix, type: :aruba do
  include_context "setup:cmd"
  describe "when loading untracked files" do
    describe "local command", :local do
      let(:file) { untracked :invalid }
      it { is_expected.to list_file(file) }
      it { is_expected.to have_exit_status(1) }
    end

    describe "origin command", :origin do
      let(:file) { untracked :invalid }
      it { is_expected.to list_file(file) }
      it { is_expected.to have_exit_status(1) }
    end
  end
end

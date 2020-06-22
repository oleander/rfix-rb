RSpec.describe Rfix, type: :aruba do
  include_context "git_new"
  let!(:head) { current_commit }

  describe "lint" do
    fdescribe "empty directory" do
      it "handles untracked file" do
        file = untracked("valid.rb")
        Rfix.load_tracked!(head)
        is_expected.to have_files(file)
      end

      it "checks for tracked file" do
        file = tracked("valid.rb")
        Rfix.load_tracked!(head)
        is_expected.to have_files(file)
      end
    end
  end
end

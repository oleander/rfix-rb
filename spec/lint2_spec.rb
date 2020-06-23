RSpec.describe Rfix do
  include_context "git_new"

  describe "lint" do
    fdescribe "Rfix.load_tracked" do
      it "handles untracked file" do
        file = untracked("valid.rb", :rand)
        Rfix.load_tracked!(rp)
        is_expected.to_not have_files(file)
      end

      it "checks for tracked file" do
        file = tracked("valid.rb")
        Rfix.load_tracked!(rp)
        is_expected.to have_files(file)
      end

      it "checks changed tracked files" do
        file = tracked("valid.rb")
        File.open(file, "a") { |h| h.write("# line") }
        Rfix.load_tracked!(rp)
        is_expected.to have_files(file)
      end
    end
  end
end

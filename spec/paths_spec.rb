RSpec.describe Rfix do
  include_context "git_new"

  describe "Rfix.load_tracked" do
    # it "returns no files on empty directory" do
    #   Rfix.load_tracked!(rp)
    #   is_expected.to have_no_files
    # end 

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

  describe "Rfix.load_untracked" do
    it "loads borth untracked and tracked" do
      file1 = tracked("valid.rb")
      file2 = untracked("valid.rb")
      Rfix.load_untracked!
      Rfix.load_tracked!(rp)
      is_expected.to have_files(file1, file2)
    end

    it "returns no files on empty directory" do
      Rfix.load_untracked!
      is_expected.to have_no_files
    end

    it "finds untracked file" do
      file = untracked("valid.rb")
      Rfix.load_untracked!
      is_expected.to have_file(file)
    end

    it "checks for tracked file" do
      file = tracked("valid.rb")
      Rfix.load_untracked!
      is_expected.to_not have_file(file)
    end

    it "checks changed tracked files" do
      file = tracked("valid.rb")
      File.open(file, "a") { |h| h.write("# line") }
      Rfix.load_untracked!
      is_expected.to_not have_file(file)
    end
  end
end

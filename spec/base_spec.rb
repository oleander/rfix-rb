RSpec.describe Rfix do
  include_context "git_new"


  describe "root_dir" do
    it "has root dir" do
      expect(Rfix.root_dir).to eq(git_path)
    end

    it "does not change dir when folders are changed" do
      extra = File.join(Rfix.root_dir, Faker::File.dir)
      FileUtils.mkdir_p(extra)
      Dir.chdir(extra) do
        expect(Rfix.root_dir).to eq(git_path)
      end
    end
  end

  describe "current_branch" do
    it "switches between branches" do
      switch("branch-1") do |branch|
        expect(Rfix.current_branch).to eq(branch)
      end

      switch("branch-2") do |branch|
        expect(Rfix.current_branch).to eq(branch)
      end
    end
  end
end

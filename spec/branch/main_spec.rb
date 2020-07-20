RSpec.describe Rfix::Branch::Main do
  describe "set & get", :git do
    it "throws error if the branch doesn't exist" do
      expect { Rfix::Branch::Main.set("nope", at: repo_path) }.to raise_error(Rfix::Branch::UnknownBranchError)
    end

    it "reads and writes", checkout: "testing" do
      Rfix::Branch::Main.set("testing", at: repo_path)
      expect(Rfix::Branch::Main.get(at: repo_path)).to eq("testing")
    end

    it "returns nil if not set" do
      expect(Rfix::Branch::Main.get(at: repo_path)).to be_nil
    end

    it "fails if path isn't a git repo" do
      Dir.mktmpdir do |tmp|
        expect { Rfix::Branch::Main.get(at: tmp) }.to raise_error(Rugged::RepositoryError)
      end
    end
  end
end

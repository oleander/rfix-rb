RSpec.describe Rfix::Branch::Main do
  describe "set & get", :git do
    xit "throws error if the branch doesn't exist" do
      expect { described_class.set("nope", at: repo_path) }.to raise_error(Rfix::Branch::UnknownBranchError)
    end

    it "reads and writes", checkout: "testing" do
      described_class.set("testing", at: repo_path)
      expect(described_class.get(at: repo_path)).to eq("testing")
    end

    it "returns nil if not set" do
      expect(described_class.get(at: repo_path)).to be_nil
    end

    it "fails if path isn't a git repo" do
      Dir.mktmpdir do |tmp|
        expect { described_class.get(at: tmp) }.to raise_error(Rugged::RepositoryError)
      end
    end
  end
end

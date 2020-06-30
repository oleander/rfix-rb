RSpec.describe Rfix::Branch::Reference do
  describe "#resolve(with:)", :git do
    describe "a named branch" do
      let(:branch) { Rfix::Branch::Reference.new("master").branch(using: repo) }

      it "resolves to named branch with commits", checkout: "stable", commits: 3 do
        expect(branch.name).to eq("master")
      end

      it "resolves to named branch with no commits", checkout: "stable", commits: 0 do
        expect(branch.name).to eq("stable")
      end
    end

    describe "a rev parse value" do
      let(:branch) { Rfix::Branch::Reference.new("HEAD~1").branch(using: repo) }

      it "resolves to named branch with commits", checkout: "stable", commits: 1 do
        expect(branch.name).to eq("master")
      end

      it "throws an error if reference doesn't exist", checkout: "stable", commits: 0 do
        expect { expect(branch.name).to eq("master") }.to raise_error(Rfix::Branch::UnknownBranchError)
      end
    end

    describe "HEAD" do
      let(:branch) { Rfix::Branch::Reference.new("HEAD").branch(using: repo) }

      it "resolves HEAD with no commits", checkout: "stable" do
        expect(branch.name).to eq("stable")
      end

      it "resolves HEAD with commits", checkout: "stable", commits: 3 do
        expect(branch.name).to eq("stable")
      end
    end
  end
end

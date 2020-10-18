RSpec.describe Rfix::Branch::Name do
  describe "#resolve(with:)", :git do
    describe "a named branch" do
      let(:branch) { Rfix::Branch::Name.new("master").resolve(with: repo) }

      it "resolves to named branch with commits", checkout: "stable", commits: 3 do
        expect(branch.name).to eq("master")
      end

      it "resolves to named branch with no commits", checkout: "stable", commits: 0 do
        expect(branch.name).to eq("stable")
      end
    end
  end
end

RSpec.describe Rfix::Branch::Head do
  describe "#resolve(with:)", :git do
    describe "a branch" do
      it "resolves to named branch with commits", checkout: "stable", commits: 3 do
        expect(Rfix::Branch::Head.new.branch(using: repo).name).to eq("stable")
      end

      it "resolves to named branch with no commits", checkout: "stable", commits: 0 do
        expect(Rfix::Branch::Head.new.branch(using: repo).name).to eq("stable")
      end
    end
  end
end

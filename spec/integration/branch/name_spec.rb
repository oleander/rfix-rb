# frozen_string_literal: true

RSpec.describe Rfix::Branch::Name do
  xdescribe "#resolve(with:)", :git do
    describe "a named branch" do
      let(:branch) { described_class.new("master").resolve(with: repo) }

      it "resolves to named branch with commits", checkout: "stable", commits: 3 do
        expect(branch.name).to eq("master")
      end

      it "resolves to named branch with no commits", checkout: "stable", commits: 0 do
        expect(branch.name).to eq("stable")
      end
    end
  end
end

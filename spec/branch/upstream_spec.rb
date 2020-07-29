RSpec.describe Rfix::Branch::Upstream do
  describe "#resolve(with:)", :git do
    describe "a named branch with upstream", checkout: "master", upstream: "master" do
      let(:branches) { Rfix::Branch::UPSTREAM.names(using: repo).map(&:name) }

      context "no commits" do
        context "same branch as upstream", checkout: "master" do
          it "resolves to current branch" do
            expect(branches).to match_array(["master"])
          end
        end

        context "different branch then upstream", checkout: "stable" do
          it "resolves to current branch" do
            expect(branches).to match_array(%w[master stable])
          end
        end
      end

      context "with commits", commits: 3 do
        context "same branch as upstream" do
          it "resolves to current branch" do
            expect(branches).to match_array([])
          end
        end

        context "different branch then upstream", checkout: "stable" do
          it "resolves to current branch" do
            expect(branches).to match_array(["master"])
          end
        end
      end
    end
  end
end

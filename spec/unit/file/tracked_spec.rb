# frozen_string_literal: true

RSpec.describe Rfix::File::Tracked, repository: "HEAD" do
  it_behaves_like "a file", :tracked? do
    its("lines.to_a") { is_expected.not_to be_empty }

    context "when not within line range" do
      let(:excluded) { (1..Float::INFINITY).lazy }

      context "when before" do
        let(:line) { excluded.drop_while(&lines.min.method(:>=)).first }

        xit "yields false" do
          expect(file.include?(line)).to eq(false), "exclude line #{line} for #{file}"
        end
      end

      context "when after" do
        let(:line) { excluded.drop_while(&lines.max.method(:>=)).first }

        it "yields false" do
          expect(file.include?(line)).to eq(false), "exclude line #{line} for #{file}"
        end
      end
    end
  end
end

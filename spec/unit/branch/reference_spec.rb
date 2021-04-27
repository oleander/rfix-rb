# frozen_string_literal: true

RSpec.describe Rfix::Branch::Reference, :repo do
  context "when reference exists" do
    let(:reference) { "HEAD" }
    subject { described_class.new(name: reference, repository: rugged) }

    its(:resolve) { is_expected.to be_a(Rugged::Commit) }
  end

  context "when reference exists" do
    let(:reference) { "HEAD~2" }
    subject { described_class.new(name: reference, repository: rugged) }

    its(:resolve) { is_expected.to be_a(Rugged::Commit) }
  end
end

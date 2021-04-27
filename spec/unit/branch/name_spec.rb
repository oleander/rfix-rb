# frozen_string_literal: true

RSpec.describe Rfix::Branch::Name, :repo do
  context "when branch exists" do
    let(:branch) { "master" }
    subject { described_class.new(name: branch, repository: rugged) }

    its(:resolve) { is_expected.to be_a(Rugged::Commit) }
  end
end

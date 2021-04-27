# frozen_string_literal: true

RSpec.describe Rfix::Branch::Upstream, :repo do
  context "when branch exists" do
    subject { described_class.new(repository: rugged) }

    its(:resolve) { is_expected.to be_a(Rugged::Commit) }
  end
end

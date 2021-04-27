# frozen_string_literal: true

RSpec.describe Rfix::Branch::Main, :repo do
  context "when branch exists" do
    subject { described_class.call(repository: rugged) }

    its(:resolve) { is_expected.to be_a(Rugged::Commit) }
  end
end

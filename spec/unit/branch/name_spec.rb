# frozen_string_literal: true

RSpec.describe Rfix::Branch::Name do
  context "when branch exists", repository: "master" do
    subject { branch }

    its(:resolve) { is_expected.to be_a(Rugged::Commit) }
  end
end

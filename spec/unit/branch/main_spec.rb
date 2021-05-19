# frozen_string_literal: true

RSpec.describe Rfix::Branch::Main, repository: "master" do
  context "when branch exists" do
    subject { branch }
    its(:resolve) { is_expected.to be_a(Rugged::Commit) }
  end
end

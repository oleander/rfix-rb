# frozen_string_literal: true

RSpec.describe Rfix::Branch::Reference do
  context "when reference exists", repository: "HEAD" do
    subject { branch }

    its(:resolve) { is_expected.to be_a(Rugged::Commit) }
  end

  context "when reference exists", repository: "HEAD~2" do
    subject { branch }

    its(:resolve) { is_expected.to be_a(Rugged::Commit) }
  end

  context "when reference is a branch name", repository: "master" do
    subject { branch }

    its(:resolve) { is_expected.to be_a(Rugged::Commit) }
  end
end

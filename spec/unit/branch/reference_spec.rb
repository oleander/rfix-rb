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

  context "when reference is a branch name" do
    let(:reference) { "master" }
    subject { described_class.new(name: reference, repository: rugged) }

    its(:resolve) { is_expected.to be_a(Rugged::Commit) }
  end

  context "when reference does not exist" do
    let(:reference) { "does_not_exist" }
    subject { described_class.new(name: reference, repository: rugged) }

    its(:resolve) { will raise_error(Rfix::Error) }
  end
end

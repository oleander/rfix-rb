# frozen_string_literal: true

RSpec.describe Rfix::Branch::Upstream, :repo do
  xcontext "when branch exists" do
    subject { described_class.new(repository: rugged) }

    before do
      rugged.config["branch.refactor.remote"] = "origin/master"
      rugged.config["branch.refactor.merge"] = "origin/master"
    end

    its(:resolve) { is_expected.to be_a(Rugged::Commit) }
  end
end

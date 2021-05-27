# frozen_string_literal: true

RSpec.xdescribe Rfix::Branch::Reference, repository: "HEAD~10" do
  subject { branch }

  its(:resolve) { is_expected.to be_a(Rugged::Commit) }
end

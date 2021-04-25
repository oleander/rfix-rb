# frozen_string_literal: true

RSpec.describe "branch", cmd: ["branch", "HEAD~2"], checkout: "stable" do
  let(:file1) { l(:invalid).tracked }
  let(:file2) { l(:invalid).tracked }

  it { is_expected.to have_fixed(file1) }
  it { is_expected.to have_fixed(file2) }
  it { is_expected.not_to have_linted(file1) }
  it { is_expected.not_to have_linted(file2) }
end

RSpec.describe "lint", cmd: ["branch", "HEAD~2"], args: ["--dry"], checkout: "stable" do
  let(:file1) { l(:invalid).tracked }
  let(:file2) { l(:valid).tracked }

  it { is_expected.to have_linted(file1) }
  it { is_expected.not_to have_fixed(file1) }
end

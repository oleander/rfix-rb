# frozen_string_literal: true

require "rspec/its"

RSpec.describe Rfix::Repository do
  subject(:repo) { described_class.call(repository: rugged, reference: branch) }

  let(:test_path) { Pathname(__dir__).join("../../tmp/complex") }
  let(:rugged) { Rugged::Repository.new(test_path) }
  let(:branch) { Rfix::Branch::Reference.new("HEAD~50") }

  its(:paths) { is_expected.to eq([]) }
  its(:head) { is_expected.to be_a(Rugged::Reference) }
  its("current_branch.name") { is_expected.to eq("master") }
  its(:local_branches) { is_expected.to eq(["master"]) }
  its(:upstream) { is_expected.to be_a(Rugged::Commit) }

  describe "#refresh!" do
    it "does not raise an error" do
      expect { repo.refresh!("Rakefile") }.not_to raise_error
    end
  end

  describe "#include?" do
    it "does not raise an error" do
      expect { repo.include?("Rakefile", 10) }.not_to raise_error
    end
  end
end

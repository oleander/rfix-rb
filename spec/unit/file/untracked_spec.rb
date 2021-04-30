# frozen_string_literal: true

RSpec.describe Rfix::File::Untracked, :repo do
  subject(:file) { described_class.call(repository: repository, basename: basename, status: status) }

  let(:basename) { "Gemfile" }
  let(:status) { Rfix::File::Base::UNTRACKED }

  describe "#path" do
    subject { file.path }

    its(:basename) { is_expected.to eq(Pathname(basename)) }
    its(:dirname) { is_expected.to eq(Pathname(dirname)) }
  end

  describe "#include?" do
    it "returns true" do
      expect(file.include?(1)).to eq(true)
    end
  end

  describe "#refresh?" do
    it "does nothing" do
      expect { file.refresh! }.not_to raise_error
    end
  end
end

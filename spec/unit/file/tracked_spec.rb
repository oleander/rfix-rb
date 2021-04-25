# frozen_string_literal: true

RSpec.describe Rfix::File::Tracked, :repo do
  subject(:file) { described_class.new(repository: rugged, basename: basename, status: status) }

  let(:basename) { "Gemfile" }
  let(:status) { Rfix::File::Base::TRACKED.first }

  describe "#path" do
    subject { file.path }

    its(:basename) { is_expected.to eq(Pathname(basename)) }
    its(:dirname) { is_expected.to eq(Pathname(dirname)) }
  end

  describe "#include?" do
    it "returns false" do
      expect(file.include?(line: 1)).to eq(false)
    end
  end

  describe "#refresh?" do
    it "does nothing" do
      expect { file.refresh! }.not_to raise_error
    end
  end
end
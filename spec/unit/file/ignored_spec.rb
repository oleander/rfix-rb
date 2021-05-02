# frozen_string_literal: true

RSpec.describe Rfix::File::Ignored, :repo do
  subject(:file) { described_class.call(repository: repository, basename: basename, status: status) }

  let(:basename) { "Gemfile" }
  let(:status) { Rfix::File::Base::IGNORED }

  describe "#path" do
    subject { file.path }

    its(:basename) { is_expected.to eq(Pathname(basename)) }
    its(:dirname) { is_expected.to eq(Pathname(dirname)) }
  end

  describe "#include?" do
    it "returns false" do
      expect(file.include?(10)).to eq(false)
    end
  end
end

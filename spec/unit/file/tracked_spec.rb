# frozen_string_literal: true

RSpec.describe Rfix::File::Tracked, :repo do
  subject(:file) { described_class.call(repository: rugged, basename: basename, status: status) }

  let(:basename) { "Gemfile" }
  let(:status) { [:added] }

  describe "#path" do
    subject { file.path }

    its(:basename) { is_expected.to eq(Pathname(basename)) }
    its(:dirname) { is_expected.to eq(Pathname(dirname)) }
  end

  describe "#include?" do
    it "returns false" do
      expect(file.include?(1)).to eq(false)
    end
  end
end

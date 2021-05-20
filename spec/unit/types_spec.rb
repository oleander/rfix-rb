# frozen_string_literal: true

RSpec.describe Rfix::Types::Status do
  subject { described_class.valid?([status]) }

  describe described_class::Ignored do
    context "when ignored" do
      let(:status) { :ignored }

      it { is_expected.to eq(true) }
    end

    context "when tracked" do
      let(:status) { :tracked }

      it { is_expected.to eq(false) }
    end
  end

  describe described_class::Untracked do
    context "when ignored" do
      let(:status) { :ignored }

      it { is_expected.to eq(false) }
    end

    context "when untracked" do
      let(:status) { :untracked }

      it { is_expected.to eq(true) }
    end
  end

  describe described_class::Tracked do
    context "when tracked" do
      let(:status) { :tracked }

      it { is_expected.to eq(true) }
    end

    context "when ignored" do
      let(:status) { :ignored }

      it { is_expected.to eq(false) }
    end
  end
end

RSpec.describe Rfix::Types::Path do
  let(:absolute) { "/a/b/c" }
  let(:relative) { absolute[1..] }

  describe described_class::Absolute do
    describe "::valid?" do
      context "when input begins with /" do
        subject { described_class.valid?(absolute) }

        it { is_expected.to eq(true) }
      end

      context "when input does not begin with /" do
        subject { described_class.valid?(relative) }

        it { is_expected.to eq(false) }
      end

      context "when input is not a string nor pathname" do
        subject { described_class.valid?(Object.new) }

        it { is_expected.to eq(false) }
      end
    end

    describe "::call" do
      context "when input is a string" do
        subject { described_class.call(absolute) }

        it { is_expected.to be_a(Pathname) }
      end

      context "when input is a pathname" do
        subject { described_class.call(Pathname(absolute)) }

        it { is_expected.to be_a(Pathname) }
      end
    end
  end

  describe described_class::Relative do
    describe "::valid?" do
      context "when input is not a string nor pathname" do
        subject { described_class.valid?(Object.new) }

        it { is_expected.to eq(false) }
      end

      context "when input begins with /" do
        subject { described_class.valid?(absolute) }

        it { is_expected.to eq(false) }
      end

      context "when input does not begin with /" do
        subject { described_class.valid?(relative) }

        it { is_expected.to eq(true) }
      end
    end

    describe "::call" do
      context "when input is a string" do
        subject { described_class.call(relative) }

        it { is_expected.to be_a(Pathname) }
      end

      context "when input is a pathname" do
        subject { described_class.call(Pathname(relative)) }

        it { is_expected.to be_a(Pathname) }
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe Rfix::File, :repo do
  let(:basename) { "Gemfile" }

  def build(status)
    described_class.call(repository: rugged, basename: basename, status: status)
  end

  describe ".call" do
    context "given untracked status" do
      Rfix::File::Base::UNTRACKED.each do |status|
        context "given status #{status.inspect}" do
          subject { build(status) }

          it { is_expected.to be_a(Rfix::File::Untracked) }
        end
      end
    end

    context "given tracked status" do
      Rfix::File::Base::TRACKED.each do |status|
        context "given status #{status.inspect}" do
          subject { build(status) }

          it { is_expected.to be_a(Rfix::File::Tracked) }
        end
      end
    end

    context "given ignored status" do
      Rfix::File::Base::IGNORED.each do |status|
        context "given status #{status.inspect}" do
          subject { build(status) }

          it { is_expected.to be_a(Rfix::File::Ignored) }
        end
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe Rfix::Repository do
  context "when HEAD", repository: "HEAD" do
    its("permitted.to_a") { is_expected.to be_empty }
    its(:paths) { is_expected.to be_empty }
    its(:to_s) { is_expected.to be_a(String) }
    its(:path) { is_expected.to be_a(Pathname) }
  end

  context "when HEAD~10", repository: "HEAD~10" do
    its("permitted.to_a") { is_expected.not_to be_empty }
    its(:paths) { is_expected.not_to be_empty }
    its(:to_s) { is_expected.to be_a(String) }
    its(:path) { is_expected.to be_a(Pathname) }
    its("paths.first") { is_expected.to be_a(String) }
  end

  context "given a file", repository: "HEAD" do
    let(:file) { Blob.new(name: "file.rb", path: repository.path) }

    context "given an untracked file" do
      context "when tracked" do
        let(:file) { super().track }

        context "then staged" do
          let(:file) { super().stage }

          it { is_expected.to track(file) }

          context "then deleted" do
            let(:file) { super().delete }

            it { is_expected.to skip(file) }
          end

          context "then changed" do
            let(:line) { 10 }
            let(:file) { super().write(to: line) }

            it { is_expected.to track(file).on_line(line) }
          end
        end

        context "then deleted" do
          let(:file) { super().delete }

          it { is_expected.to skip(file) }
        end

        context "then changed" do
          let(:file) { super().write }

          it { is_expected.to track(file) }
        end

        context "given an untracked file" do
          let(:file) { super().add("file2.rb") }

          it { is_expected.not_to track(file) }

          context "then staged" do
            let(:file) { super().stage }

            it { is_expected.not_to track(file) }
          end

          context "then deleted" do
            let(:file) { super().delete }

            it { is_expected.not_to skip(file) }
          end
        end
      end
    end
  end
end

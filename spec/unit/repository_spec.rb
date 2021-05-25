# frozen_string_literal: true

RSpec.describe Rfix::Repository do
  context "when HEAD", repository: "HEAD" do
    its("permitted.to_a") { is_expected.to be_empty }
    its(:paths) { is_expected.to be_empty }
    its(:to_s) { is_expected.to be_a(String) }
    its(:path) { is_expected.to be_a(Pathname) }
    it { is_expected.not_to include(repository.path.join("does-not-exist.rb")) }
  end

  context "when HEAD~10", repository: "HEAD~10" do
    its("permitted.to_a") { is_expected.not_to be_empty }
    its(:paths) { is_expected.not_to be_empty }
    its(:to_s) { is_expected.to be_a(String) }
    its(:path) { is_expected.to be_a(Pathname) }

    describe "#files" do
      subject { repository.files }

      it { is_expected.to all(exist) }
    end

    describe "#paths" do
      subject(:paths)  { repository.paths }

      it { is_expected.to all(be_a(String))}

      it 'only contains relative paths' do
        paths = repository.paths.map { |p| Pathname(p) }
        expect(paths).to all(be_relative)
      end
    end

    describe "#include?" do
      context "when file exists" do
        let(:file) { repository.path.join(repository.paths.first) }
        it { is_expected.to include(file) }
      end

      context "when file does not exists" do
        let(:file) { repository.path.join("does-not-exist.rb") }
        it { is_expected.not_to include(file) }
      end

      context "when path is relative" do
        it "raises an error" do
          expect { repository.include?("relative.rb") }.to raise_error(Dry::Types::ConstraintError)
        end
      end
    end
  end

  xcontext "given a file", repository: "HEAD" do
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

            it { is_expected.to track(file) }
          end

          context "then deleted" do
            let(:file) { super().delete }

            it { is_expected.to skip(file) }
          end
        end
      end
    end
  end
end

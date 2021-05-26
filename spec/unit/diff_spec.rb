
 RSpec.shared_examples_for "a diff" do
  its("lines.to_a") { is_expected.not_to be_empty }
  its("files.to_a") { is_expected.not_to be_empty }
  its("deltas.to_a") { is_expected.not_to be_empty }
 end

RSpec.describe Rfix::Diff, repository: "HEAD~50" do
  context "when in non-empty sub folder" do
    it_behaves_like "a diff" do
      subject { described_class.new(current_path: "lib", repository: repository) }

      its("files.to_a") { is_expected.to all(exist) }
    end
  end

  context "when in an empty sub folder" do
    its("lines.to_a") { is_expected.to be_empty }
    its("files.to_a") { is_expected.to be_empty }
    its("deltas.to_a") { is_expected.to be_empty }

    let(:empty_path) { repository.path.join("empty") }

    before do
      empty_path.mkdir
    end

    subject { described_class.new(current_path: "empty", repository: repository) }
  end

  context "when in an non-existing sub folder" do
    subject { described_class.new(current_path: "does-not-exist", repository: repository) }

    its("lines.to_a") { will raise_error(Rfix::Error) }
    its("files.to_a") { will raise_error(Rfix::Error) }
    its("deltas.to_a") { will raise_error(Rfix::Error) }
  end

  context "when given a file instead of a directory" do
    before do
      pp repository.paths
    end
    let(:current_file) { Pathname(repository.paths.first).relative_path_from(repository.path) }
    subject { described_class.new(current_path: current_file, repository: repository) }

    its("lines.to_a") { will raise_error(Rfix::Error) }
    its("files.to_a") { will raise_error(Rfix::Error) }
    its("deltas.to_a") { will raise_error(Rfix::Error) }
  end

  context "when in project folder" do
    it_behaves_like "a diff" do
      subject { described_class.new(current_path: ".", repository: repository) }

      its("files.to_a") { is_expected.to all(exist) }
    end
  end
end

require "tty/screen"

RSpec.shared_examples "a file" do |selector|
  let(:rugged) { Rugged::Repository.new(repo_path) }
  let(:branch) { Rfix::Branch::Reference.new(name: "HEAD~45") }
  let(:repository) { Rfix::Repository.new(repository: rugged, reference: branch) }
  let(:bundle_path) { Pathname.pwd.join("spec/fixtures/repository") }
  let(:repo_path) { expand_path("repository") }
  let(:files) { repository.files }
  let(:lines) { file.lines }

  subject(:file) { repository.files.detect(&selector) || fail("No files") }

  before do
    system "mkdir", "-p", repo_path
    system "git", "clone", bundle_path.to_s, repo_path, "--quiet", "--branch", "master"
  end

  after do |example|
    if example.exception
      ("-" * TTY::Screen.width).then do |dashed|
        puts [dashed, "FILE: #{file}", dashed].join("\n")
      end
    end
  end

  describe "#class" do
    its(:class) { is_expected.to eq(described_class) }
  end

  describe "#basename" do
    subject { Pathname(file.basename) }

    it { is_expected.to be_relative }
  end

  describe "#key" do
    its(:key) { is_expected.to be_a(String) }
    its(:key) { is_expected.not_to be_empty }
    its(:key) { is_expected.to end_with(file.basename.to_s) }
  end

  describe "#to_table" do
    its(:to_table) { is_expected.to be_a(Array) }
    its(:to_table) { is_expected.not_to be_empty }
  end

  describe "#to_s" do
    its(:to_s) { is_expected.to start_with(file.basename.to_s) }
  end

  describe "#inspect" do
    its(:inspect) { is_expected.to include(file.basename.to_s) }
  end

  describe "#include?" do
    context 'when within line range' do
      it 'yields true' do
        lines.each do |line|
          expect(file.include?(line)).to eq(true), "include line #{line}"
        end
      end
    end
  end
end

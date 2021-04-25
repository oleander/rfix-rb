# frozen_string_literal: true

require "rspec/its"
require 'rspec/expectations'

RSpec::Matchers.define :stage do |file|
  match do |repository|
    repository.staged.any? do |path|
      path.basename == file.name
    end
  end

  failure_message do |repository|
    "expected that #{repository} would include staged file #{file.name}"
  end
end

RSpec::Matchers.define :ignore do |file|
  match do |repository|
    repository.ignored.any? do |path|
      path.basename == file.name
    end
  end

  failure_message do |repository|
    "expected that #{repository} would include ignored file #{file.name}"
  end
end

RSpec::Matchers.define :track do |file|
  match do |repository|
    repository.tracked.any? do |path|
      path.basename == file.name
    end
  end

  match_when_negated do |repository|
    repository.untracked.any? do |path|
      path.basename == file.name
    end
  end

  failure_message do |repository|
    "expected that #{repository} would include tracked file [#{file.name}]"
  end

  failure_message_when_negated do |repository|
    "expected that #{repository} would include untracked file [#{file.name}]"
  end
end

require 'tmpdir'

class Blob < Struct.new(:name)
  def self.new(*)
    blob = super
    blob.init
    blob.touch
    blob
  end

  def new(name)
    self.class.new(name)
  end

  def delete
    tap { file_path.delete }
  end

  def stage
    write.tap { git.add(name) }
  end

  def status
    tap { puts git.status.pretty }
  end

  def commit
    stage.tap do
      git.commit("commit #{name}")
    end
  end
  alias_method :track, :commit

  def ignore
    tap do
      path.join(".gitignore").write(name, mode: 'a')
    end
  end

  def path
    @path ||= Pathname(Dir.mktmpdir)
  end

  def repo
    @repo ||= Rugged::Repository.new(path)
  end

  def write
    tap { file_path.write("# comment", mode: 'a') }
  end

  def file_path
    path.join(name)
  end

  def touch
    puts "Touch #{name}"
    tap { path.join(name).write("") }
  end

  def git
    @git ||= Git.init(path.to_s)
  end
  alias_method :init, :git
end

# let(:test_path) { Pathname(__dir__).join("../../tmp/complex") }
# let(:rugged) { Rugged::Repository.new(test_path) }

# its(:paths) { is_expected.to eq([]) }
# its(:head) { is_expected.to be_a(Rugged::Reference) }
# its("current_branch.name") { is_expected.to eq("master") }
# its(:local_branches) { is_expected.to eq(["master"]) }
# its(:upstream) { is_expected.to be_a(Rugged::Commit) }
#
# describe "#refresh!" do
#   it "does not raise an error" do
#     expect { repo.refresh!("Rakefile") }.not_to raise_error
#   end
# end

RSpec.describe Rfix::Repository do
  let(:file) { Blob.new(name) }
  let(:branch) { Rfix::Branch::Reference.new("HEAD") }

  # before do
  #   file.write_comment.commit
  # end


  # describe "#include?" do
  #   after { file.delete }
  #
  #   let(:name) { "file.rb" }
  #
  #   context "when file is tracked then modified" do
  #     before { file.write }
  #     it { is_expected.to track(name) }
  #   end
  #
  #   context "when file is untracked" do
  #     before { file.new("file2.rb").write }
  #     it { is_expected.to track(name) }
  #   end
  #
  #   context "when file is ignored" do
  #     before { file.ignore }
  #     it { is_expected.to ignore(name) }
  #   end
  #
  #   context "when file is commited" do
  #     before { file.write.commit }
  #
  #     it { is_expected.to track(name) }
  #   end
  # end

  subject(:repository) { described_class.call(repository: file.repo, reference: branch) }

  after do |example|
    if example.exception
      # repository.status
      # binding.pry
    end
  end

  context "given an untracked file" do
    let(:file) { Blob.new("file.rb") }

    context "when tracked" do
      let(:file) { super().track }

      it { is_expected.to track(file) }

      context "then staged" do
        let(:file) { super().stage }

        it { is_expected.to track(file) }

        context "then deleted" do
          let(:file) { super().delete }

          it { is_expected.to ignore(file) }
        end

        context "then changed" do
          let(:file) { super().write }

          it { is_expected.to track(file) }
        end
      end

      context "then deleted" do
        let(:file) { super().delete }

        it { is_expected.to ignore(file) }
      end

      context "given an untracked file" do
        let(:file) { super().new("file2.rb") }

        it { is_expected.not_to track(file) }
      end
    end
  end
end

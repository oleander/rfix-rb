# frozen_string_literal: true

require "rspec/its"
require "rspec/expectations"

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

RSpec::Matchers.define :skip do |file|
  match do |repository|
    repository.skipped.any? do |path|
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

require "tmpdir"

Blob = Struct.new(:name) do
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
      path.join(".gitignore").write(name, mode: "a")
    end
  end

  def path
    @path ||= Pathname(Dir.mktmpdir)
  end

  def repo
    @repo ||= Rugged::Repository.new(path)
  end

  def write
    tap { file_path.write("# comment", mode: "a") }
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

RSpec.describe Rfix::Repository do
  subject(:repository) { described_class.call(repository: file.repo, reference: branch) }

  let(:file) { Blob.new(name) }
  let(:branch) { Rfix::Branch::Reference.new("HEAD") }

  after do |example|
    if example.exception
      puts repository.status
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

          it { is_expected.to skip(file) }
        end

        context "then changed" do
          let(:file) { super().write }

          it { is_expected.to track(file) }
        end
      end

      context "then deleted" do
        let(:file) { super().delete }

        it { is_expected.to skip(file) }
      end

      context "given an untracked file" do
        let(:file) { super().new("file2.rb") }

        it { is_expected.not_to track(file) }

        context "then staged" do
          let(:file) { super().stage }

          it { is_expected.not_to track(file) }
        end
      end
    end
  end
end

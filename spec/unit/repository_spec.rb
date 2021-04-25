# frozen_string_literal: true

require "rspec/its"
require 'rspec/expectations'

RSpec::Matchers.define :ignore_file do |name|
  match do |repository|
    repository.ignored.any? do |path|
      path.basename == name
    end
  end

  failure_message do |repository|
    "expected that #{repository} would include ignored file #{name}"
  end
end

RSpec::Matchers.define :track_file do |name|
  match do |repository|
    repository.tracked.any? do |path|
      path.basename == name
    end
  end

  failure_message do |repository|
    "expected that #{repository} would include tracked file #{name}"
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

  def delete
    puts "Delete #{name}"
    path.rmtree
  end

  def staged
    puts "Add #{name}"
    tap { git.add(name) }
  end

  def status
    tap { puts git.status.pretty }
  end

  def commit
    puts "Commit #{name}"
    staged.tap do
      git.commit("commit #{name}")
    end
  end

  def path
    @path ||= Pathname(Dir.mktmpdir)
  end

  def repo
    @repo ||= Rugged::Repository.new(path)
  end

  def write_comment
    puts "Write to #{name}"
    tap { file_path.write("# comment", mode: 'a') }
  end
  alias write write_comment

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

  before do
    file.write_comment.commit
  end

  subject(:repo) { described_class.call(repository: file.repo, reference: branch) }

  describe "#include?" do
    after { file.delete }

    let(:name) { "file.rb" }

    context "when file is untracked" do
      it { is_expected.to ignore_file(name) }
    end

    context "when file is staged" do
      before { file.staged.status }

      it { is_expected.to ignore_file(name) }
    end

    context "when file is commited" do
      before { file.write.commit }

      it { is_expected.to track_file(name) }
    end
  end
end

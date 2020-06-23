require "git"
require "faker"

RSpec.shared_context "git_new", shared_context: :metadata do
  include_context "setup"

  def dump!
    status.dump!
  end

  def head
    git.object("HEAD").sha
  end

  def tracked(file, *args)
    dst_path = to_random(path: file)
    copy "%/#{file}", dst_path
    git.add(dst_path)
    git.commit("Adding #{dst_path} to repo")
    dst_path
  end

  def untracked(file, *args)
    dst_path = to_random(path: file)
    copy "%/#{file}", dst_path
    dst_path
  end

  before(:each) do
    is_expected.to be_clean
    expect(Rfix.paths).to be_empty
  end

  private

  def to_random(path:)
    Faker::File.file_name(ext: File.extname(path).delete_prefix("."))
  end
end

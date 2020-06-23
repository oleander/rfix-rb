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

  def tracked(file)
    copy "%/#{file}", file
    git.add(file)
    git.commit("Adding #{file} to repo")
    file
  end

  def untracked(file, *args)
    dst_path = file
    if args.include?(:rand)
      ext = File.extname(file)
      dst_path = Faker::File.file_name(ext: ext.delete_prefix("."))
    end

    copy "%/#{file}", dst_path
    dst_path
  end
end

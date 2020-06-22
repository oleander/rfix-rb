require "git"

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

  def untracked(file)
    copy "%/#{file}", file
    file
  end
end

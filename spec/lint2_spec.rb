require "git"

RSpec.shared_context "git_new", shared_context: :metadata do
  include_context "setup"

  def dump!
    status.dump!
  end

  def head
    git.object("HEAD").sha
  end

  def include(file)
    copy "%/#{file}", file
    git.add(file)
    git.commit("Adding #{file} to repo")
    file
  end
end


RSpec.describe Rfix, type: :aruba do
  include_context "git_new"

  it "works with the git gem" do
    copy "%/rubocop.yml", ".rubocop.yml"
    copy "%/valid.rb", "valid2.rb"

    git.add("valid2.rb")
    git.commit('A commit message')

    say git.status.pretty

    copy "%/valid.rb", "valid.rb"

    is_expected.to be_dirty

    git.add(".rubocop.yml")
    git.add("valid.rb")
    git.commit('A commit message')

    is_expected.to be_clean
  end

  let!(:head) { current_commit }

  describe "lint" do
    describe "empty directory" do
      it "has checked zero files" do
        # Rfix.load_tracked!("HEAD")
        # expect(Rfix.paths).to be_empty
      end

      it "has checked zero files" do
        file = include("valid.rb")
        Rfix.load_tracked!(head)
        is_expected.to have_files(file)
      end
    end
  end
end

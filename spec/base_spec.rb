# https://github.com/ruby-git/ruby-git/blob/e44c18ec6768c0c76603d20915118a201d0ec340/lib/git/base.rb
require "pry"
RSpec.describe Rfix do
  include_context "git_new"

  describe "root_dir" do
    it "has root dir" do
      expect(Rfix.root_dir).to eq(git_path)
    end

    it "does not change dir when folders are changed" do
      extra = File.join(Rfix.root_dir, Faker::File.dir)
      FileUtils.mkdir_p(extra)
      Dir.chdir(extra) do
        expect(Rfix.root_dir).to eq(git_path)
      end
    end
  end

  describe "current_branch" do
    it "switches between branches" do
      # say git.branches.local
      # binding.pry
      # say git.current_branch
      switch("branch-1") do |branch|
        expect(Rfix.current_branch).to eq(branch)
      end

      switch("branch-2") do |branch|
        expect(Rfix.current_branch).to eq(branch)
      end

    end

    it "handles nameless branch" do
      2.times { tracked }
      git.checkout("HEAD~1")
      expect(Rfix.current_branch).to include("HEAD")
    end
  end
end

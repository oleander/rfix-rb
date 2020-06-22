require "git"

RSpec.shared_context "git_new", shared_context: :metadata do
  let(:repo) { Dir.mktmpdir("git", expand_path(".")) }
  subject(:g) { Git.init(repo) }
  let(:status) { g.status }

  around(:each) do |example|
    g.chdir { example.run }
  end

  def dump!
    status.dump!
  end
end

RSpec.describe Rfix, type: :aruba do
  include_context "git_new"

  it "works" do
    copy "%/rubocop.yml", ".rubocop.yml"
    copy "%/valid.rb", "valid2.rb"

    g.add("valid2.rb")
    g.commit('A commit message')

    say g.status.pretty

    copy "%/valid.rb", "valid.rb"

    is_expected.to be_dirty

    g.add(".rubocop.yml")
    g.add("valid.rb")
    g.commit('A commit message')

    is_expected.to be_clean
  end
end

# RSpec.fdescribe "lint", cmd: ["branch", "HEAD~2"], args: ["--dry"], checkout: "stable" do

RSpec.describe "the branch command" do
  describe "preload", cmd: %w[branch master], checkout: "stable" do
    it_behaves_like "a command"
    it_behaves_like "a destroyed file"
  end
end

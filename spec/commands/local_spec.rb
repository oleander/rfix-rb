RSpec.describe "the local command", :local, type: :aruba do
  it_behaves_like "a command"
  it_behaves_like "a destroyed file"

  describe "linting like behaviour", args: [:dry, :untracked] do
    it_behaves_like "a lint command"
  end
end

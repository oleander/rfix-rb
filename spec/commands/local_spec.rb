RSpec.describe "the local command", type: :aruba do
  describe "preload", :local do
    it_behaves_like "a command"
    it_behaves_like "a destroyed file"

    describe "linting like behaviour", args: [:dry, :untracked] do
      it_behaves_like "a lint command"
    end
  end

  it_behaves_like "a command that accepts files" do
    let(:command) { "local" }
  end
end

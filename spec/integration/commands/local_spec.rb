# frozen_string_literal: true

RSpec.describe "the local command", upstream: "master", checkout: "stable" do
  describe "preload", cmd: "local" do
    it_behaves_like "a command"
    it_behaves_like "a destroyed file"

    describe "linting like behaviour", args: ["--dry", "--untracked"] do
      it_behaves_like "a lint command"
    end
  end

  it_behaves_like "a command that accepts files" do
    let(:command) { "local" }
  end
end

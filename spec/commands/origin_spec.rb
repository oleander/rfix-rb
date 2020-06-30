RSpec.describe "the origin command", checkout: "stable" do
  describe "preload", cmd: "origin" do
    it_behaves_like "a command"
    it_behaves_like "a destroyed file"
  end

  it_behaves_like "a command that accepts files" do
    let(:command) { "origin" }
  end
end

RSpec.describe "the branch command", type: :aruba do
  describe "preload", :branch do
    it_behaves_like "a command"
    it_behaves_like "a destroyed file"
  end

  # TODO
  # it_behaves_like "a command that accepts files" do
  #   let(:command) { "branch master" }
  # end
end

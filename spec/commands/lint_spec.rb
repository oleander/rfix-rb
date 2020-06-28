RSpec.describe "lint command", :lint, type: :aruba do
  it_behaves_like "a lint command"
  it_behaves_like "a destroyed file"
end

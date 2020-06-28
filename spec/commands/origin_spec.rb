RSpec.describe "the origin command", :origin, type: :aruba do
  it_behaves_like "a command"
  it_behaves_like "a destroyed file"
end

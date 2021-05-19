RSpec.shared_examples "a skipped file" do |selector|
  it_behaves_like "a file", selector do
    describe "#include?" do
      it { is_expected.not_to include(1) }
    end
  end
end

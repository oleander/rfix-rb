# frozen_string_literal: true

RSpec.describe Rfix::File::Untracked do
  context "when file is located in root folder" do
    it_behaves_like "a file", :untracked? do
      before do
        example_file.write("# a comment\n")
      end

      let(:example_file) { repository.path.join("example.rb") }

      its(:lines) { is_expected.to be_empty }
    end
  end

  context "when file is located in sub folder" do
    it_behaves_like "a file", :untracked? do
      before do
        example_file.dirname.mkpath
        example_file.write("# a comment\n")
      end

      let(:example_file) { repository.path.join("sub1/sub2/example.rb") }

      its(:lines) { is_expected.to be_empty }
    end
  end
end

# require "git"
#
# RSpec.shared_context "git", shared_context: :metadata do
#   let(:bundle_path) { File.join(__dir__, "..", "tmp", "snapshot.bundle") }
#   let(:repo) { Dir.mktmpdir("rspec", expand_path(".")) }
#   let!(:g) { Git.clone(bundle_path, "test-repo", path: repo) }
#
#   around(:each) do |example|
#     cd(repo) { example.run }
#   end
# end

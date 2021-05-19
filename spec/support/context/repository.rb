RSpec.shared_context :repository, shared_context: :metadata, type: :aruba do
  let(:rugged) { Rugged::Repository.new(repo_path) }
  let(:branch) { |m| Rfix::Branch::Reference.new(name: m.metadata.fetch(:repository)) }
  let(:repository) { Rfix::Repository.new(repository: rugged, reference: branch) }
  let(:bundle_path) { Pathname.pwd.join("spec/fixtures/repository") }
  let(:repo_path) { expand_path("repository") }
  let(:files) { repository.files }

  before do
    system "mkdir", "-p", repo_path
    system "git", "clone", bundle_path.to_s, repo_path, "--quiet"
  end

  subject { repository }
end

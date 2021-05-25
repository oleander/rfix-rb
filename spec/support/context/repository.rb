# frozen_string_literal: true

RSpec.shared_context "repository", shared_context: :metadata, type: :aruba do
  subject { repository }

  let(:rugged) { Rugged::Repository.new(repo_path) }
  let(:branch) { |m| Rfix::Branch::Reference.new(name: m.metadata.fetch(:repository)) }
  let(:repository) { Rfix::Repository.new(repository: rugged, reference: branch) }
  let(:bundle_path) { Pathname.pwd.join("spec/fixtures/repository") }
  let(:repo_path) { expand_path("repository") }
  let(:files) { repository.files }

  before do
    system "rm", "-rf", repo_path.to_s
    system "mkdir", "-p", repo_path.to_s
    system "git", "clone", bundle_path.to_s, repo_path.to_s, "--quiet"
    system "rm", "#{repo_path}/.rubocop.yml"
    cd repo_path.to_s
  end
end

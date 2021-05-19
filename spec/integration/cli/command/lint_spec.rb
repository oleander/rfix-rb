# frozen_string_literal: true

RSpec.describe Rfix::CLI::Command::Lint, repository: "HEAD" do
  it_behaves_like "a command", "lint HEAD~5"
end

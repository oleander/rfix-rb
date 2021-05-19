# frozen_string_literal: true

RSpec.describe Rfix::CLI::Command::Branch, repository: "HEAD" do
  it_behaves_like "a command", "branch HEAD~5"
end

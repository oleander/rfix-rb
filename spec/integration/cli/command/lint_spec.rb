# frozen_string_literal: true

RSpec.describe Rfix::CLI::Command::Lint do
  it_behaves_like "a command", "lint HEAD~5"
end

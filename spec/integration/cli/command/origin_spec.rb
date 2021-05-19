# frozen_string_literal: true

RSpec.describe Rfix::CLI::Command::Origin, repository: "HEAD" do
  it_behaves_like "a command", "origin"
end

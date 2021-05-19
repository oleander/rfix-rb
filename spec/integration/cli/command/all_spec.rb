# frozen_string_literal: true

RSpec.describe Rfix::CLI::Command::All, repository: "HEAD" do
  it_behaves_like "a command", "all"
end

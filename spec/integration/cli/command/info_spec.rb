# frozen_string_literal: true

RSpec.describe Rfix::CLI::Command::Info, repository: "HEAD" do
  it_behaves_like "a command", "info"
end

# frozen_string_literal: true

RSpec.xdescribe Rfix::CLI::Command::Setup, repository: "HEAD" do
  it_behaves_like "a command", "setup"
end

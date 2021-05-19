# frozen_string_literal: true

RSpec.xdescribe Rfix::CLI::Command::Help, repository: "HEAD" do
  it_behaves_like "a command", "help"
end

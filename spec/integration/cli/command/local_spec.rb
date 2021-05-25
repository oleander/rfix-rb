# frozen_string_literal: true

RSpec.describe Rfix::CLI::Command::Local, repository: "HEAD" do
  it_behaves_like "a command", "local" do
  end
end

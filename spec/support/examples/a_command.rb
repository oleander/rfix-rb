# frozen_string_literal: true

RSpec.shared_examples "a command" do |command|
  context "given a command", type: :aruba do
    let(:bin_path) { root_path.join("exe/rfix") }

    before { run_command("#{bin_path} #{command}") }

    it { expect(last_command_started).to be_successfully_executed }
  end
end

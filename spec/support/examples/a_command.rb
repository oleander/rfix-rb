# frozen_string_literal: true

RSpec.shared_examples "a command" do |command|
  context "given a command", repository: "HEAD~10" do
    let(:bin_path) { root_path.join("exe/rfix") }

    before do
      cd repository.path.to_s
      run_command("#{bin_path} #{command}")
    end

    it do
      expect(last_command_started).to be_successfully_executed
    end
  end
end

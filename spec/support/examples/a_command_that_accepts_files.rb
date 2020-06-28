RSpec.shared_examples "a command that accepts files" do
  describe "successful passing files" do
    it "only effects those files that are passed in" do
      checkout("master", "stable")
      upstream("master")

      file1 = f(:invalid).tracked.write!
      file2 = f(:invalid).tracked.write!

      config = File.expand_path(File.join(__dir__, "../../fixtures/rubocop.yml"))

      run_command_and_stop("rfix #{command} --root #{repo} --config #{config} --main-branch master #{file1.to_path}")

      file1.all_line_changes.each do |line|
        expect(last_command_started).to find_path(file1.to_path).with_line(line)
      end

      file2.all_line_changes.each do |line|
        expect(last_command_started).to_not find_path(file2.to_path).with_line(line)
      end

      expect(all_stdout).to include("corrected")
    end
  end
end

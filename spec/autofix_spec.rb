RSpec.describe Rfix, type: :aruba do
  describe "autofix" do
    it "fails on second config with line length == 5" do
      cmt = current_commit
      expect do
        copy "%/rubocop.yml", ".rubocop-default.yml"
        copy "%/rubocop-line-length-5.yml", ".rubocop.yml"
        git "add", ".rubocop.yml", ".rubocop-default.yml"
        commit
      end.to change { total_commits }.by(1)

      expect do
        add_file_and_commit(content: "this-is-a-long-line")
      end.to change { total_commits }.by(1)

      expect(dirty?).to eq(false)

      expect do
        branch_cmd(branch: cmt, dry: false)
      end.to change { no_changed_files }.by(1)
    end

    it "default configuration files has a maximum line length of 120" do
      cmt          = current_commit
      the_rb_file  = add_valid_file
      the_yml_file = add_rubocop_config

      expect(dirty?).to eq(false)

      expect do
        branch_cmd(branch: cmt, dry: false, debug: true)
      end.to_not change { no_changed_files }

      expect(all_output).to include(the_rb_file)
      expect(all_output).to include(the_yml_file)
      expect(all_output).to include("2 paths")
    end
  end
end

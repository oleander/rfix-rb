# RSpec.describe Rfix, type: :git do
#   describe "autofix" do
#     it "fails on second config with line length == 5" do
#       test_branch = "test-branch"
#       checkout(test_branch)
#       expect do
#         copy "%/rubocop.yml", ".rubocop-default.yml"
#         copy "%/rubocop-line-length-5.yml", ".rubocop.yml"
#         git.add(".rubocop.yml")
#         git.add(".rubocop-default.yml")
#         git.commit("Adding RuboCop config files")
#       end.to change { total_commits }.by(1)
#
#       expect do
#         add_file_and_commit(content: "this-is-a-long-line")
#       end.to change { total_commits }.by(1)
#
#       expect(dirty?).to eq(false)
#
#       expect do
#         branch_cmd(branch: test_branch, dry: false)
#       end.to change { no_changed_files }.by(1)
#
#       expect(dirty?).to eq(true)
#     end
#
#     it "default configuration files has a maximum line length of 120" do
#       cmt          = current_commit
#       the_rb_file  = add_valid_file
#       the_yml_file = add_rubocop_config
#
#       expect(dirty?).to eq(false)
#
#       expect do
#         branch_cmd(branch: cmt, dry: false, debug: false)
#       end.to_not change { no_changed_files }
#
#       is_expected.to have_paths_count(2)
#       is_expected.to have_files(the_rb_file, the_yml_file)
#     end
#   end
# end

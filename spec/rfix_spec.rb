#
# RSpec.describe Rfix, type: :aruba do
#   let(:rubocop_help_arg) { ["--parallel"] }
#
#   subject { last_command_started }
#
#   describe "no files and no changes" do
#     describe "local" do
#       before { local_cmd }
#       subject { all_output }
#       it { is_expected.to have_no_files }
#     end
#
#     describe "origin" do
#       before { origin_cmd }
#       subject { all_output }
#       it { is_expected.to have_no_files }
#     end
#
#     describe "branch" do
#       before { branch_cmd }
#       subject { all_output }
#       it { is_expected.to have_no_files }
#     end
#   end
#
#   describe "no upstream for local" do
#     before do
#       setup_test_branch
#       local_cmd
#     end
#
#     it { is_expected.to_not find("no upstream") }
#     xit { is_expected.to find(ref_for_branch) }
#   end
#
#   describe "info" do
#     before { default_cmd("info") }
#     subject { last_command_started }
#
#     %w[Rfix RuboCop OS Git Ruby].each do |param|
#       it { is_expected.to have_output(/#{param}/) }
#     end
#
#     it { is_expected.to have_exit_status(0) }
#   end
#
#   describe "--untrackeed" do
#
#     describe "with" do
#       describe "branch" do
#         before do
#           checkout("master", "stable")
#           @file = untracked :invalid
#           branch_cmd(untracked: true)
#         end
#
#         it { is_expected.to list_file(@file) }
#         it { is_expected.to have_exit_status(1) }
#       end
#
#       describe "local" do
#         before do
#           checkout("master", "stable")
#           upstream("master")
#           @file = untracked :invalid
#           local_cmd(untracked: true)
#         end
#
#         it { is_expected.to list_file(@file) }
#         it { is_expected.to have_exit_status(1) }
#       end
#
#       describe "origin" do
#         before do
#           checkout("master", "stable")
#           upstream("master")
#           @file = untracked :invalid
#           origin_cmd(untracked: true)
#         end
#
#         it { is_expected.to list_file(@file) }
#         it { is_expected.to have_exit_status(1) }
#       end
#     end
#
#     describe "without" do
#       describe "branch" do
#         before do
#           checkout("master", "stable")
#           @file = untracked :invalid
#           branch_cmd(untracked: false)
#         end
#
#         it { is_expected.to_not list_file(@file) }
#         it { is_expected.to have_exit_status(0) }
#       end
#
#       describe "local" do
#         before do
#           checkout("master", "stable")
#           upstream("master")
#           @file = untracked :invalid
#           local_cmd(untracked: false)
#         end
#
#         it { is_expected.not_to list_file(@file) }
#         it { is_expected.to have_exit_status(0) }
#       end
#
#       describe "origin" do
#         before do
#           checkout("master", "stable")
#           upstream("master")
#           @file = untracked :invalid
#           origin_cmd(untracked: false)
#         end
#
#         it { is_expected.to_not list_file(@file) }
#         it { is_expected.to have_exit_status(0) }
#       end
#     end
#   end
#
#   describe "--dry" do
#     before do
#       setup_test_branch(upstream: :master)
#     end
#
#     describe "all" do
#       describe "with" do
#         it "does not alter files" do
#           expect { default_cmd("all", dry: true) }.to change { no_changed_files }.by(0)
#         end
#       end
#
#       describe "without" do
#         it "does alter files" do
#           expect { default_cmd("all", dry: false) }.to change { no_changed_files }.by(19)
#         end
#       end
#     end
#
#     describe "branch" do
#       before do
#         checkout("master", "stable")
#         tracked :invalid
#       end
#
#       it "makes no change when used" do
#         expect { branch_cmd(dry: true) }.to_not change { no_changed_files }
#       end
#
#       it "makes change when left out" do
#         expect { branch_cmd(dry: false) }.to change { no_changed_files }.by(1)
#       end
#     end
#
#     describe "local" do
#       before { tracked :invalid }
#
#       it "makes no change when used" do
#         expect { local_cmd(dry: true) }.to_not change { no_changed_files }
#       end
#
#       it "makes change when left out" do
#         expect { local_cmd(dry: false); }.to change { no_changed_files }.by(1)
#       end
#     end
#
#     describe "origin" do
#       it "makes no change when used" do
#         expect { origin_cmd(dry: true) }.to_not change { no_changed_files }
#       end
#
#       it "makes change when left out" do
#         expect { origin_cmd(dry: false) }.to change { no_changed_files }.by(8)
#       end
#     end
#   end
#
#   describe "--help" do
#     describe "with" do
#       before { default_cmd("", help: true) }
#       it { is_expected.to find(*rubocop_help_arg) }
#     end
#
#     describe "without" do
#       before { default_cmd("", help: false) }
#       it { is_expected.not_to find(*rubocop_help_arg) }
#     end
#   end
#
#   describe "fixed" do
#     before do
#       setup_test_branch(upstream: :test)
#     end
#
#     describe "origin" do
#       before { origin_cmd }
#       it { is_expected.to have_files_count(8) }
#     end
#
#     describe "local" do
#       before { local_cmd }
#       it { is_expected.to have_no_files }
#     end
#
#     describe "branch" do
#       before { branch_cmd }
#       it { is_expected.to have_files_count(8) }
#     end
#   end
#
#   describe "local" do
#     let!(:file_name) { tracked :invalid }
#     before { local_cmd }
#     it { is_expected.to have_fixed(file_name) }
#   end
#
#   # Set branch to master
#   # Create new branch
#   # Create and commit file
#   # Lint
#   describe "status codes" do
#     describe "has files" do
#       # let(:before_branch) { "master" }
#       # let(:path) { "invalid.rb" }
#       # let!(:file) { tracked :invalid, path: path }
#       # before { file; checkout(before_branch); checkout("stable") }
#
#       describe "branch" do
#         describe "fixable" do
#           before do
#             checkout("master", "stable")
#             @file = tracked :invalid
#             branch_cmd(branch: "master", dry: false)
#           end
#
#           it { is_expected.to list_file(@file) }
#           it { is_expected.to have_exit_status(0) }
#           it { is_expected.to have_fixed(@file) }
#         end
#
#         describe "unfixable" do
#           before do
#             checkout("master", "stable")
#             @unfixable = tracked :invalid
#             @fixable = tracked :unfixable
#             branch_cmd(branch: "master", dry: false)
#           end
#
#           it { is_expected.to list_file(@unfixable) }
#           it { is_expected.to list_file(@fixable) }
#           it { is_expected.to have_exit_status(1) }
#           it { is_expected.to have_fixed(@fixable) }
#         end
#       end
#
#       fdescribe "origin" do
#         setup_origin do
#           @file = untracked :invalid
#         end
#
#         it { is_expected.to have_exit_status(1) }
#         it { is_expected.to list_file(@file) }
#       end
#
#       describe "local" do
#         it "handles new files" do
#           checkout("master", "stable")
#           upstream("master")
#           other_file = tracked :invalid
#           local_cmd
#           is_expected.to list_file(other_file)
#           is_expected.to have_exit_status(1)
#         end
#       end
#     end
#
#     describe "no files" do
#       describe "branch" do
#         before { branch_cmd }
#         subject { last_command_started }
#         it { is_expected.to have_no_files }
#         it { is_expected.to have_exit_status(0) }
#       end
#
#       describe "local" do
#         before { local_cmd }
#         subject { last_command_started }
#         it { is_expected.to have_no_files }
#         it { is_expected.to have_exit_status(0) }
#       end
#
#       describe "local" do
#         before { origin_cmd }
#         subject { last_command_started }
#         it { is_expected.to have_no_files }
#         it { is_expected.to have_exit_status(0) }
#       end
#     end
#   end
#
#   describe "fails" do
#     it "displays help when no command is given" do
#       expect { default_cmd("") }.to_not change { no_changed_files }
#       is_expected.to find("Valid rfix")
#       is_expected.to have_exit_status(1)
#     end
#
#     it "displays help when an invalid command is given" do
#       expect { default_cmd("not-a-command") }.to_not change { no_changed_files }
#       is_expected.to find("Valid rfix")
#       is_expected.to have_exit_status(1)
#     end
#
#     it "displays help even when an invalid command is given" do
#       expect { default_cmd("not-a-command", help: true) }.to_not change { no_changed_files }
#       is_expected.to_not find("Valid rfix")
#       is_expected.to find(*rubocop_help_arg)
#       is_expected.to have_exit_status(0)
#     end
#   end
#
#   describe "change" do
#     before do
#       setup_test_branch(upstream: :master)
#     end
#
#     it "defaults to zero" do
#       expect(no_changed_files).to eq(0)
#     end
#
#     describe "run" do
#       describe "with" do
#         it "origin" do
#           expect { origin_cmd(dry: false) }.to change { no_changed_files }.by(6)
#           is_expected.to find("30 offenses corrected")
#           is_expected.to find("30 offenses detected")
#           expect(last_command_started).to have_exit_status(0)
#         end
#
#         it "local" do
#           checkout("test")
#           upstream("test")
#           expect { local_cmd(dry: false) }.to change { no_changed_files }.by(0)
#           add_file_and_commit # Add a file
#           expect { local_cmd(dry: false) }.to change { no_changed_files }.by(1)
#           is_expected.to find("4 offenses detected")
#           is_expected.to find("4 offenses corrected")
#           expect(last_command_started).to have_exit_status(0)
#         end
#
#         it "branch" do
#           expect { branch_cmd(dry: false) }.to change { no_changed_files }.by(6)
#           is_expected.to find("30 offenses detected")
#           is_expected.to find("30 offenses corrected")
#           expect(last_command_started).to have_exit_status(0)
#         end
#       end
#
#       describe "without" do
#         it "origin" do
#           expect { origin_cmd(dry: true) }.to_not change { no_changed_files }
#           is_expected.not_to find("corrected")
#           expect(last_command_started).to have_exit_status(1)
#         end
#
#         describe "local" do
#           it "does not alter the filesystem" do
#             checkout("master", "stable")
#             upstream("master")
#             file1 = untracked :invalid
#             expect { local_cmd(dry: true) }.to_not change { no_changed_files }
#             is_expected.to list_file(file1)
#             file2 = untracked :invalid
#             expect { local_cmd(dry: true) }.to_not change { no_changed_files }
#             is_expected.to list_file(file2)
#             is_expected.not_to find("corrected")
#             is_expected.to have_exit_status(1)
#           end
#         end
#
#         describe "branch" do
#           it "does not alter files on the filesystem" do
#             checkout("master", "stable")
#
#             unfixable = tracked :invalid
#             fixable = tracked :unfixable
#
#             expect { branch_cmd(dry: true) }.to_not change { no_changed_files }
#             is_expected.not_to find("corrected")
#             is_expected.to have_exit_status(1)
#           end
#         end
#       end
#     end
#   end
# end

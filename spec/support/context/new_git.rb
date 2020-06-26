# require "git"
# require "faker"
#
# RSpec.shared_context "git_new", shared_context: :metadata do
#   # include_context "setup"
#
#   def dump!
#     status.dump!
#   end
#
#   def head
#     git.object("HEAD").sha
#   end
#
#   def current_branch
#     git.branch.name
#   end
#
#   def switch(branch)
#     git.branch(branch).create
#     git.checkout(branch)
#     yield(branch)
#   end
#
#   before(:each) do
#     is_expected.to be_clean
#     expect(Rfix.paths).to be_empty
#     git.branch("master").checkout
#   end
# end

# frozen_string_literal: true

r_args = []

helper("help", binding)
helper("rubocop", binding)
helper("args", binding)

param :branch
usage "rfix branch BRANCH [opts] [-p path ..]"
option :p, :path, "Path to be passed to RuboCop", argument: :required, multiple: true
summary "Fix changes made between HEAD and <branch>"

run do |opts, args, _cmd|
  branch = Rfix::Branch::Reference.new(args[:branch])
  setup(r_args, opts, args, files: opts[:path] || [], reference: branch)
end

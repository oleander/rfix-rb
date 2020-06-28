r_args = []

helper("help", binding)
helper("rubocop", binding)
helper("args", binding)

param :branch
option :p, :path, "Path to be passed to RuboCop", argument: :required, multiple: true
summary "Fix changes made between HEAD and <branch>"

run do |opts, args, _cmd|
  setup(r_args, opts, args, files: opts[:path], reference: args[:branch])
end

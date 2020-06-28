r_args = []

helper("help", binding)
helper("rubocop", binding)
helper("args", binding)

param :branch
summary "Branch"
run do |opts, args, _cmd|
  setup(r_args, opts, args, reference: args[:branch]) do |repo|
    # Nop
  end
end

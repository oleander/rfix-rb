r_args   = []

helper("help", binding)
helper("rubocop", binding)
helper("args", binding)

summary "Local"
run do |opts, args, cmd|
  setup(r_args, opts, args, reference: "@{upstream}")
end

r_args = []

helper("help", binding)
helper("rubocop", binding)
helper("args", binding)

summary "Auto-fixes commits not yet pushed to upstream"

run do |opts, args, _cmd|
  setup(r_args, opts, args, files: args.each.to_a, reference: "@{upstream}")
end

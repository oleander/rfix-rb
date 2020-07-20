r_args = []

helper("help", binding)
helper("rubocop", binding)
helper("args", binding)

summary "Auto-fixes commits not yet pushed to upstream"
usage "rfix local [opts] [path ..]"

run do |opts, args, _cmd|
  setup(r_args, opts, args, files: args.each.to_a, reference: Rfix::Branch::UPSTREAM)
end

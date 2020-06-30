r_args = []

helper("help", binding)
helper("rubocop", binding)
helper("args", binding)

summary "Auto-fixes commits between HEAD and origin branch"
usage "rfix origin [opts] [path ..]"

run do |opts, args, _cmd|
  if main = opts[:"main-branch"]
    branch = Rfix::Branch::Name.new(main)
  else
    branch = Rfix::Branch::MAIN
  end

  # say "Using {{red:#{branch}}} as main branch"
  setup(r_args, opts, args, files: args.each.to_a, reference: branch)
end

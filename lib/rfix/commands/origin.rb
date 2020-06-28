r_args = []

helper("help", binding)
helper("rubocop", binding)
helper("args", binding)

summary "Auto-fixes commits between HEAD and origin branch"
usage "rfix origin [opts] [path ..]"

run do |opts, args, _cmd|
  if opts.key?(:"main-branch")
    branch = opts[:"main-branch"]
  elsif branch = Rfix::Repository.main_branch(for_path: opts[:root])
    branch = branch
  else
    branch = say_abort "No main branch set, please run {{command:rfix setup}} first"
  end

  say "Using {{red:#{branch}}} as main branch"
  setup(r_args, opts, args, files: args.each.to_a, reference: branch)
end

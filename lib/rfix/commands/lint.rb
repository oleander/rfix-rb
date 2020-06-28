r_args   = []

helper("help", binding)
helper("rubocop", binding)
helper("args", binding)

summary "Shortcut for {{command:local --dry --untracked}}".fmt
description "Lint (read-only) files"

run do |opts, args, cmd|
  opts[:dry] = true
  opts[:untracked] = true

  branch = if opts.key?(:"main-branch")
    opts[:"main-branch"]
  elsif branch = Rfix::Repository.main_branch(for_path: opts[:root])
    branch
  else
    say_abort "No main branch set, please run {{command:rfix setup}} first"
  end

  setup(r_args, opts, args, reference: branch)
end

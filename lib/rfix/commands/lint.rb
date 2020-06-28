r_args = []

helper("help", binding)
helper("rubocop", binding)
helper("args", binding)

summary "Lints commits and untracked files not yet pushed to upstream"
description "Lint (read-only) files"

run do |opts, args, _cmd|
  opts[:dry] = true
  opts[:untracked] = true

  if opts.key?(:"main-branch")
    branch = opts[:"main-branch"]
  elsif branch = Rfix::Repository.main_branch(for_path: opts[:root])
    branch = branch
  else
    branch = say_abort "No main branch set, please run {{command:rfix setup}} first"
  end

  setup(r_args, opts, args, reference: branch)
end

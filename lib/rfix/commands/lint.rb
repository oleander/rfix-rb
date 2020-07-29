r_args = []

helper("help", binding)
helper("rubocop", binding)
helper("args", binding)

summary "Lints commits and untracked files not yet pushed to upstream"
usage "rfix lint [opts] [path ..]"
description "Lint (read-only) files"

run do |opts, args, _cmd|
  opts[:dry] = true
  opts[:untracked] = true

  if main = opts[:"main-branch"]
    branch = Rfix::Branch::Name.new(main)
  else
    branch = Rfix::Branch::MAIN
  end

  setup(r_args, opts, args, files: args.each.to_a, reference: branch)
end

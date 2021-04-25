# frozen_string_literal: true

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

  branch = if main = opts[:"main-branch"]
             Rfix::Branch::Name.new(main)
           else
             Rfix::Branch::MAIN
           end

  setup(r_args, opts, args, files: args.each.to_a, reference: branch)
end

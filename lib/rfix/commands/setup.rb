helper("help", binding)

option :r, :root, "{{*}} Project root path", default: Dir.pwd, argument: :required
option :b, :"main-branch", "{{*}} Branch to use", argument: :optional

summary "Sets the default branch for {{command:rfix local}}"

def set_branch(root_path, branch)
  Rfix::Branch::Main.set(branch, at: root_path)
  say "Main branch was set to {{italic:#{branch}}}"
end

run do |opts, _args|
  if branch = Rfix::Branch::Main.get(at: opts[:root])
    say "Current main branch set to {{info:#{branch}}}"
  end

  if branch = opts[:"main-branch"]
    next set_branch(opts[:root], branch)
  end

  CLI::UI::Prompt.ask("Which one is your main branch?") do |handler|
    Rfix::Branch.local(at: opts[:root]).each do |branch|
      handler.option(branch) do
        set_branch(repo, branch)
      end
    end
  end

  if branch = Rfix::Branch::Main.get(at: opts[:root])
    say "Your main branch has been set to {{info:#{branch}}}"
  else
    say_error "No main branch has been set"
  end
end

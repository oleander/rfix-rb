helper("help", binding)

option :r, :root, "{{*}} Project root path", default: Dir.pwd, argument: :required
option :b, :"main-branch", "{{*}} Branch to use", argument: :optional

summary "Sets the default branch for {{command:rfix local}}"

def set_branch(repo, branch)
  repo.set_main_branch(branch)
  say "Set main branch to {{italic:#{branch}}}"
rescue Rfix::Error => e
  say_abort e.to_s
end

run do |opts, args|
  begin
    repo = Rfix::Repository.new(root_path: opts[:root])
  rescue Rfix::Error => e
    say_abort e.to_s
  end

  if branch = repo.main_branch
    say "Current main branch set to {{info:#{branch}}}"
  end

  if branch = opts[:"main-branch"]
    next set_branch(repo, branch)
  end

  CLI::UI::Prompt.ask("Which one is your main branch?") do |handler|
    repo.local_branches.each do |local_branch|
      handler.option(local_branch) do
        set_branch(repo, local_branch)
      end
    end
  end
end

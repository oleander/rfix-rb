r_args = []

helper("help", binding)

summary "Setup"

run do |_opts, _args, _cmd|
  CLI::UI::Prompt.ask("Which one is your main branch?") do |handler|
    repo = Rfix::Repository.new(Dir.pwd, nil)

    if branch = repo.main_branch
      say "Current main branch set to {{info:#{branch}}}"
    end

    repo.local_branches.each do |branch|
      handler.option(branch) do
        repo.set_main_branch(branch)
        say "Main branch set to {{info:#{branch}}}"
      end
    end
  end
end

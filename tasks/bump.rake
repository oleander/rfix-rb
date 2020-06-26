namespace :build do
  task :bump do
    sh "gem", "bump", "-c", "-m", "Bump version to %{version}"
  end

  task "bundle:install"
end

# sh "bundle", "install"
# cmd("git add Gemfile.lock")
# cmd("git commit --amend --no-edit")

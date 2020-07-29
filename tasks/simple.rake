namespace :bundle do
  namespace :simple do
    directory Bundle::Simple::REPO

    desc "Build complex bundle"
    task build: [Bundle::Simple::FILE, Bundle::Simple::TEST] do
      say "Simple bundle has been stored @ #{Bundle::Simple::FILE}"
    end

    desc "Rebuild complex bundle"
    task rebuild: [:flush, Bundle::Simple::BUILD]

    desc "Remove complex bundle"
    task :flush do
      rm_f Bundle::Simple::FILE
      rm_rf Bundle::Simple::REPO
    end

    desc "Test repo by cloning to local directory"
    task test: Bundle::Simple::FILE do
      Dir.mktmpdir do |repo|
        sh "git clone", Bundle::Simple::FILE, repo, "--branch master"
        cd repo do
          sh "git rev-list --count HEAD"
          sh "git ls-files"
          sh "git status"
        end
      end

      say "Finished testing simple bundle"
    end

    file Bundle::Simple::FILE => Bundle::Simple::REPO do
      cd Bundle::Simple::REPO do
        sh "git bundle create", Bundle::Simple::FILE, "--branches --tags"
      end
    end

    file Bundle::Simple::REPO do
      cd Bundle::Simple::REPO do
        touch ".gitignore"

        sh "git init"
        sh "git add .gitignore"

        sh "git config user.email 'you@example.com'"
        sh "git config user.name 'Your Name'"

        sh "git commit -m 'A Commit Message'"

        sh "git config push.default current"
        sh "git config branch.autosetupmerge always"
        sh "git config branch.autosetuprebase always"

        sh "git config user.email 'not-my@real-email.com'"
        sh "git config user.name 'John Doe'"

        sh "git tag", Bundle::Simple::TAG
      end
    end
  end
end

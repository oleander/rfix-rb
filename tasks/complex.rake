require "tmpdir"

namespace :bundle do
  namespace :complex do
    directory Bundle::TMP

    desc "Build complex bundle"
    task build: [Bundle::Complex::FILE, Bundle::Complex::TEST] do
      say "Complex bundle has been stored @ #{Bundle::Complex::FILE}"
    end

    desc "Rebuild complex bundle"
    task rebuild: [:flush, Bundle::Complex::BUILD]

    desc "Remove complex bundle"
    task :flush do
      rm_f Bundle::Complex::FILE
      rm_rf Bundle::Complex::REPO
    end

    desc "Test repo by cloning to local directory"
    task test: Bundle::Complex::FILE do
      Dir.mktmpdir do |repo|
        sh "git clone", Bundle::Complex::FILE, repo, "--branch master"
        cd repo do
          sh "git rev-list --count HEAD"
          sh "git ls-files"
          sh "git status"
        end
      end

      say "Finished testing complex bundle"
    end

    file Bundle::Complex::FILE => Bundle::Complex::REPO do
      cd Bundle::Complex::REPO do
        sh "git bundle create", Bundle::Complex::FILE, "--branches --tags"
      end
    end

    file Bundle::Complex::REPO do
      sh "git clone", Bundle::Complex::GITHUB, Bundle::Complex::REPO, "--branch", "master"

      cd Bundle::Complex::REPO do
        sh "git", "reset --hard 27fec8"

        sh "git config user.email 'not-my@real-email.com'"
        sh "git config user.name 'John Doe'"

        sh "git tag", Bundle::Complex::TAG
      end
    end
  end
end

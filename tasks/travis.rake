RSpec::Core::RakeTask.new(:rspec)

namespace :travis do
  desc "Set up dependencies"
  task setup: [Vendor::BUILD, Bundle::BUILD, Travis::GIT]

  desc "Install gem"
  task Travis::INSTALL => Travis::SETUP do
    Rake::Task[:install].invoke
  end

  desc "Run test suite"
  task spec: Travis::SETUP do
    Rake::Task[:rspec].invoke
  end

  desc "Verify bin on CI"
  task verify: [Travis::INSTALL, Travis::TASKS]

  namespace :git do
    task :config do
      sh "git config --global user.email 'not-my@real-email.com'"
      sh "git config --global user.name 'John Doe'"
    end
  end

  namespace :tasks do
    desc "Run this"
    task all: [:welcome, :info]

    task :rfix do
      clone_and_run do
        sh "rfix"
      end
    end

    task :info do
      clone_and_run do
        sh "rfix info"
      end
    end

    task :help do
      clone_and_run do
        sh "rfix --help"
      end
    end

    task :welcome do
      clone_and_run do
        sh "rfix welcome"
      end
    end
  end
end

task :codeGen do
  sleep rand
end

task compile: :codeGen do
  say "in compile"
  sleep rand
end

task dataLoad: :codeGen do
  say "in data"
  # sleep rand
end

task gtest: [:compile, :dataLoad] do
  say "in test"
  sleep rand
end

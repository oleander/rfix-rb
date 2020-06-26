RSpec::Core::RakeTask.new(:rspec)

namespace :travis do
  desc "Set up dependencies"
  multitask setup: [Vendor::BUILD, Bundle::BUILD]

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

  namespace :tasks do
    desc "Run this"
    multitask all: [:welcome, :info]

    task :rfix do
      clone_and_run do |path|
        sh "rfix", *args(path)
      end
    end

    task :info do
      clone_and_run do |path|
        sh "rfix info", *args(path)
      end
    end

    task :help do
      clone_and_run do |path|
        sh "rfix --help", *args(path)
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

task :compile => :codeGen do
  say "in compile"
  sleep rand
end

task :dataLoad => :codeGen do
  say "in data"
  # sleep rand
end

task :gtest => [:compile, :dataLoad] do
  say "in test"
  sleep rand
end

  # frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'fileutils'
require "rfix"
require "rfix/rake_helper"

RSpec::Core::RakeTask.new(:spec)
extend RakeHelper

task default: :spec

desc "Install gems not in the gemspec or gemfile"
namespace :vendor do
  task :download do
    say "Download external gems, hold on ..."
    clone(github: "shopify/cli-ui", ref: "ef976df676f4")
    clone(github: "oleander/git-fame-rb", ref: "a9b9c25bbab1")
  end

  task :clear do
    say "Remove and create vendor folder"
    FileUtils.remove_dir("vendor/shopify")
    FileUtils.remove_dir("vendor/oleander")
  end
end

desc "Install dependencies in the correct order"
namespace :bundle do
  task :install do
    say "Running {{command:bundle install}} with gemspec"
    cmd "bundle install"
  end
end


desc "Set user.* for global git user"
namespace :git do
  task :config do
    cmd("git config --global user.email hello@world.com")
    cmd("git config --global user.name John Doe")
    result = cmd("git config --global -l").first
    say "Git config set to {{yellow:#{result}}}"
  end

  namespace :install do
    task :osx do
      say "Installing git on OS X"
      cmd("brew install #{brew_url(ref: "140da7e09919887e1040f726db22dafd0cffe4d9")}")
    end

    task :linux do
      say("Skip linux for now")
    end

    task :guess do
      osx? ? Rake::Task["git:install:osx"].invoke : Rake::Task["git:install:linux"].invoke
    end
  end
end

namespace :gemfile do
  task :update do
    gemfiles.each do |gemfile|
      say "Update #{gemfile}"
      cmd("bundle", "update", "--gemfile", gemfile)
    end
  end

  namespace :locks do
    task :clear do
      gemlocks.each do |lock|
        say "Remove #{lock}"
        FileUtils.remove_file(lock, true)
      end
    end
  end

  task :install do
    gemfiles.each do |gemfile|
      say "Bundle install #{gemfile}"
      cmd("bundle", "install", "--gemfile", gemfile)
    end
  end

  task commit: :update do
    cmd("git", "commit", "-a", "-m", "Ran bundle install")
  end
end

task :rehash do
  cmd("rbenv", "rehash")
end

task :bump do
  cmd("gem", "bump", "-c", "-m", "Bump version to %{version}")
end

task clear: ["vendor:clear", "gemfile:locks:clear"]
task setup: ["vendor:download", "gemfile:install", "gemfile:update"]
task local: [:setup, :install]
task reset: [:clear, :setup]

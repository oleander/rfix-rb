  # frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'fileutils'
require 'rfix'

include Rfix::Log
include Rfix::Cmd

RSpec::Core::RakeTask.new(:spec)

def source_for(name:)
  bundle_root = Bundler.bundle_path.join('bundler/gems')
  path = Dir.glob(bundle_root.join("#{name}-*").to_s).first
  path or raise "Could not find source for #{name}, run bundle install first"
end

def dest_for(name:)
  File.join(__dir__, 'vendor', name)
end

def setup(gem:)
  say "Setup gem {{yellow:#{gem}}}"
  Bundler.setup(gem)

  source = source_for(name: gem)
  say "Load source {{yellow:#{source}}}"

  dest = dest_for(name: gem)
  say "Load dest {{yellow:#{dest}}}"

  FileUtils.mkdir_p(dest)
  say "Copy files"
  FileUtils.copy_entry source, dest, true, true, true
end

task default: :spec

task :bundle_install do
  say "Running bundle install"
  cmd "bundle install"
end

task setup: [:bundle_install] do
  setup(gem: "cli-ui")
  setup(gem: "git-fame-rb")
end

def osx?
  ENV.fetch("TRAVIS_OS_NAME") == "osx"
end

def brew_url(ref:)
  "https://raw.githubusercontent.com/Homebrew/homebrew-core/#{ref}/Formula/git.rb"
end

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

def dirty?
  !cmd_succeeded?("git diff --quiet")
end

namespace :gemfile do
  task :update do
    say_abort "Dirty repository, commit first" if dirty?
    Dir.glob("ci/Gemfile*").unshift("Gemfile").reject do |path|
      File.extname(path) == ".lock"
    end.each do |gemfile|
      say "Update #{gemfile}"
      cmd("bin/bundle", "update", "--gemfile", gemfile)
    end
  end

  task commit: :update do
    cmd("git", "commit", "-a", "-m", "Ran bundle install")
  end
end

task :rehash do
  cmd("rbenv", "rehash")
end

task local: [:setup, :install]

# gem bump --pretend | cat

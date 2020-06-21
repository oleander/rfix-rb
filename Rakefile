  # frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'fileutils'
require 'rfix'

include Rfix::Log
include Rfix::Cmd

RSpec::Core::RakeTask.new(:spec)

def dirty?
  !cmd_succeeded?("git diff --quiet")
end

def gemfiles
  Dir.glob("ci/Gemfile*").unshift("Gemfile").reject do |path|
    [".lock", ".base"].include?(File.extname(path))
  end
end

def source_for(name:)
  bundle_root = Bundler.bundle_path.join('bundler/gems')
  path = Dir.glob(bundle_root.join("#{name}-*").to_s).first
  path or raise "Could not find source for #{name}, run bundle install first"
end

def dest_for(name:)
  File.join(__dir__, 'vendor', name)
end

def setup(gem:)
  say "Gem {{info:#{gem}}}"
  Bundler.setup(gem)

  source = source_for(name: gem)
  say "Source {{info:#{source}}}"

  dest = dest_for(name: gem)
  say "Dest {{info:#{dest}}}"

  FileUtils.mkdir_p(dest)
  say "Symlink {{info:#{gem}}}"
  FileUtils.symlink(source, dest, force: true)
end

def no_gemspec
  say "Disable gemspec group"
  cmd("bundle config set without 'gemspec'")
  yield
  say "Enable gemspec group"
  cmd("bundle config unset without")
end

def deployment
  say "Enable deployment"
  cmd("bundle config set deployment 'true'")
  yield
  say "Disable deployment"
  cmd("bundle config set deployment 'false'")
end

def osx?
  ENV.fetch("TRAVIS_OS_NAME") == "osx"
end

def brew_url(ref:)
  "https://raw.githubusercontent.com/Homebrew/homebrew-core/#{ref}/Formula/git.rb"
end

task default: :spec

namespace :bundle do
  task :install do
    no_gemspec do
      say "Running {{command:bundle install}} without gemspec"
      cmd "bundle install"
    end

    say "Running {{command:bundle install}} with gemspec"
    cmd "bundle install"
  end
end

namespace :symlink do
  task gems: ["bundle:install"] do
    setup(gem: "git-fame-rb")
    setup(gem: "cli-ui")
  end
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

namespace :gemfile do
  task :update do
    gemfiles.each do |gemfile|
      say "Update #{gemfile}"
      cmd("bundle", "update", "--gemfile", gemfile)
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

task local: [:setup, :install]

# gem bump --pretend | cat

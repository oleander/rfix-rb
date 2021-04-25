  # frozen_string_literal: true

require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require_relative "lib/rfix/rake/paths"
require_relative "lib/rfix/rake/support"

Dir[File.join(__dir__, "tasks/*")].each(&method(:load))

extend Rfix::Rake::Support

desc "Remove and create tmp file"
task :clear do
  rm_rf Bundle::TMP
end

desc "Rebuild vendor and bundles"
task rebuild: [:clear, Vendor::REBUILD, Bundle::REBUILD]

desc "Build bundles for testing"
task Bundle::BUILD => [Bundle::Complex::BUILD, Bundle::Simple::BUILD]

desc "Rebuild bundles for testing"
task Bundle::REBUILD => [Bundle::Complex::REBUILD, Bundle::Simple::REBUILD]

# desc "Bump to a new version of rfix"
task bump: "gem:bump"

task spec: Bundle::BUILD do
  sh "bundle", "exec", "rspec", "spec"
end

task default: [:rebuild]

require "rake/clean"
require "pathname"

namespace :testing do
  project_path = Pathname.pwd
  repo_path = project_path.join("tmp/test")
  last_commit_hash = "526654c"
  first_commit_hash = "a20ce6d"
  rfix = project_path.join("bin/rfix")
  rubocop_config_path = repo_path.join(".rubocop.yml")
  repo_url = "https://github.com/fazibear/colorize.git"

  # CLEAN.include(repo_path)

  gemfile = <<~GEMFILE
    source 'https://rubygems.org'
    gem "rubocop"
  GEMFILE

  file repo_path do
    sh "git", "clone", repo_url, "--branch", "master", repo_path

    cd repo_path do
      sh "git", "reset", "--hard", last_commit_hash
      rm "Gemfile"
    end

    repo_path.join("Gemfile").write(gemfile)

    cd repo_path do
      sh "bundle install"
      sh "bundle exec rubocop --init"
    end
  end

  task lint: repo_path do
    cd repo_path do
      sh rfix, "branch", first_commit_hash, "--fail-level=F"
    end
  end
end

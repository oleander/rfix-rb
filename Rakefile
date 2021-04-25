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
  test_path = project_path.join("tmp/test")
  repo_path = test_path.join("repo")
  bundle_file = test_path.join("repo.bundle")
  fixed_tag = "rfix-fixed-tag"
  workspace_path = test_path.join("workspace")
  last_commit_hash = "526654c"
  first_commit_hash = "a20ce6d"
  tag = "rfix-checkpoint-tag"
  rfix = project_path.join("bin/rfix")
  repo_url = "https://github.com/fazibear/colorize.git"

  config_path = workspace_path.join(".rubocop.yml")
  gem = workspace_path.join(".rubocop.yml")

  # CLEAN.include(workspace_path)

  directory repo_path, test_path

  gemfile = <<~GEMFILE
    source 'https://rubygems.org'
    gem "rubocop"
  GEMFILE

  file repo_path do
    sh "git", "clone", repo_url, "--branch", "master", repo_path

    cd repo_path do
      rm "Gemfile"
      rm ".rubocop.yml"
    end

    repo_path.join("Gemfile").write(gemfile)

    cd repo_path do
      sh "bundle install"
      sh "bundle exec rubocop --init"
      sh "git add ."
      sh "git", "commit", "-m", "'Test commit'"
      sh "git tag", tag
    end
  end

  file bundle_file => repo_path do
    cd repo_path do
      sh "git bundle create", bundle_file, "--branches", "--tags"
    end
  end

  file workspace_path => bundle_file do
    sh "git", "clone", bundle_file, "--branch", tag, workspace_path
  end

  task lint: workspace_path do
    cd workspace_path do
      sh rfix, "branch", first_commit_hash, "--fail-level", "F"
      sh "git add ."
      sh "git commit -m 'rfix fixes'"
      sh "git", "tag", fixed_tag

      sh "git", "reset", "--hard", "HEAD~1"
      sh "bundle exec rubocop -A --fail-level F"
      sh "git add ."
      sh "git commit -m 'native fixes'"

      sh "git", "diff", fixed_tag
    end
  end

  task :soft_clean do
    cd workspace_path do
      sh "git", "tag", "-d", fixed_tag
      sh "git", "checkout", "."
      sh "git", "reset", "--hard", tag
    end
  end

  task :clean do
    rm_rf repo_path
    rm_rf test_path
  end
end

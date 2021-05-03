# frozen_string_literal: true

require "git"
require "logger"
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "dry/core/constants"
require_relative "lib/rfix/rake/paths"
require_relative "lib/rfix/rake/support"

Dir[File.join(__dir__, "tasks/*")].each(&method(:load))

extend Rfix::Rake::Support

desc "Remove and create tmp file"
task :clear do
  rm_rf Bundle::TMP
end

desc "Rebuild vendor and bundles"
task rebuild: [:clear, "vendor:rebuild", Bundle::REBUILD]

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
  first_commit_hash = "HEAD"
  tag = "rfix-checkpoint-tag"
  rfix = project_path.join("bin/rfix")
  repo_url = "https://github.com/fazibear/colorize.git"

  config_path = workspace_path.join(".rubocop.yml")
  gem = workspace_path.join(".rubocop.yml")

  # CLEAN.include(workspace_path)

  directory test_path

  gemfile = <<~GEMFILE
    source 'https://rubygems.org'
    gem "rubocop"
  GEMFILE

  example = <<~EXAMPLE
    # This is a comment
  EXAMPLE

  directory repo_path

  file repo_path do
    mkdir_p repo_path

    cd repo_path do
      touch "Gemfile"
    end

    repo_path.join("Gemfile").write(gemfile)

    git = Git.init(repo_path.to_path, log: Logger.new($stdout))

    git.chdir do
      touch ".gitignore"

      sh "bundle install --local"
      sh "bundle exec rubocop --init"
      sh "bundle exec rubocop -A"
    end

    git.add(all: true)
    git.commit_all("changes")

    git.branch("child").checkout

    repo_path.join("example.rb").write(example)

    git.add("example.rb")
    git.commit("example.rb")
    git.add_tag(tag)

    git.chdir do
      sh "git bundle create", bundle_file, "--branches", "--tags"
    end
  end

  file workspace_path => bundle_file do
    sh "git", "clone", bundle_file, "--branch", "child", workspace_path

    cd workspace_path do
      sh "git", "checkout", "master"
      sh "git", "checkout", "child"
    end
  end

  namespace :lint do
    task rfix: workspace_path do
      git = Git.open(workspace_path.to_path, log: Logger.new($stdout))
      #
      # git.checkout("master")
      # git.add_tag(fixed_tag)
      # next
      #
      git.checkout("child")

      git.chdir do
        sh rfix, "setup", "-b", "master"
        sh rfix, "origin", "--fail-level", "F"
      end

      git.add(all: true)
      git.commit_all("changes")
      git.add_tag(fixed_tag)
      git.reset_hard("HEAD~1")
    end

    task rubocop: workspace_path do
      git = Git.open(workspace_path.to_path, log: Logger.new($stdout))

      git.checkout("child")

      git.chdir do
        sh "bundle exec rubocop -A --fail-level F"
      end

      git.add(all: true)
      git.commit("changes")
    end

    task diff: %i[rfix rubocop] do
      cd workspace_path do
        sh "git", "diff", fixed_tag
      end
    end
  end

  task soft_clean: workspace_path do
    cd workspace_path do
      begin
        sh("git", "tag", "-d", fixed_tag)
      rescue StandardError
        nil
      end
      sh "git", "checkout", "."
      sh "git", "reset", "--hard", tag
    end
  end

  task rebuild: [:clean, workspace_path]

  task :clean do
    rm_f bundle_file
    rm_rf workspace_path
    rm_rf repo_path
    rm_rf test_path
  end
end

def gemfile(version)

end

def gemfile(version)
  Pathname("Gemfile.rubocop-#{version}")
end

def lockfile(version)
  Pathname(gemfile(version).to_s + ".lock")
end

class Gemfile < Struct.new(:root, :version)
  include Dry::Core::Constants, FileUtils

  FORMAT = "Gemfile.rubocop-%s%s"

  def call
    puts "Working with #{version}"

    gemfile.write(content)

    if lockfile.exist?
      lockfile.delete
    end

    sh "bundle", "lock", "--gemfile", gemfile.to_path
    puts "Finished with #{version}"
  end

  def gemfile
    root.join(FORMAT % [version, EMPTY_STRING])
  end

  def lockfile
    root.join(FORMAT % [version, ".lock"])
  end

  def content
    <<~GEMFILE
      eval_gemfile("../Gemfile")
      gem "rubocop", "#{version}"
    GEMFILE
  end
end

namespace :bundle do
  task :gemfile do
    Pathname(__dir__).join("gemfiles").then do |root_path|
      ['0.84', '0.92', '0.93', '1.0.0', '1.10.0', '1.13.0'].map do |version|
        Thread.new do
          Gemfile.new(root_path, version).call
        end
      end.each(&:join)
    end
  end

  task :lock do
    gemfiles_path.then do |gemfiles_path|
      gemfiles_path.glob("*.lock").each(&:delete)
      gemfiles_path.glob("*[!lock]").map do |path|
        Thread.new do
          sh "bundle", "lock", "--gemfile", path.to_s
        end
      end.each(&:join)
    end
  end
end

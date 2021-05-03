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

namespace :bundle do
  task :rspec do
    Pathname(__dir__).join("gemfiles").then do |root_path|
      Rfix::Rake::Gemfile.files(root_path).each_slice(5) do |gemfiles|
        gemfiles.map do |gemfile|
          Thread.new do
            sh "bundle", "exec", "--gemfile", gemfile.to_s, "rspec"
          end
        end.each(&:join)
      end
    end
  end

  task :install do
    Pathname(__dir__).join("gemfiles").then do |root_path|
      Rfix::Rake::Gemfile.files(root_path).each_slice(5) do |gemfiles|
        gemfiles.map do |gemfile|
          Thread.new do
            gemfile.call
          end
        end.each(&:join)
      end
    end
  end
end

  # frozen_string_literal: true

require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require_relative "lib/rfix/rake/paths"
require_relative "lib/rfix/rake/support"

Dir[File.join(__dir__, "tasks/*")].each(&method(:load))

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

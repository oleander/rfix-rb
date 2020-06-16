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

task local: [:setup, :install]

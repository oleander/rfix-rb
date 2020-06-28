require "rbconfig"
require "rugged"

extend Rfix::Log
extend Rfix::Cmd

def git_version
  cmd("git --version").last.split(/\s+/, 3).last
end

def ruby_version
  RbConfig::CONFIG["ruby_version"] || "<unknown>"
end

def current_os
  RbConfig::CONFIG["host_os"] || "<unknown>"
end

helper("help", binding)

summary "Displays useful debug information"

run do |_opts, _args|
  say "Using RuboCop {{info:#{RuboCop::Version.version}}}"
  say "Using Rugged {{info:#{Rugged::VERSION}}}"
  say "Using Rfix {{info:#{Rfix::VERSION}}}"
  say "Using OS {{info:#{current_os}}}"
  say "Using Git {{info:#{git_version}}}"
  say "Using Ruby {{info:#{ruby_version}}}"
end

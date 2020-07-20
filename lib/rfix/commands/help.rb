extend Rfix::Log

summary "Displays help"

run do |_opts, _args, cmd|
  prt cmd.supercommand.help
end

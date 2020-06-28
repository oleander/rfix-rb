extend Rfix::Log

name        'help'
summary     'Displays help'

run do |opts, args, cmd|
  prt cmd.supercommand.help
end

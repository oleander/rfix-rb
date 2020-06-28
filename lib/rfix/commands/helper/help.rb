extend Rfix::Log

flag   :h,  :help,  'show help for this command' do |value, cmd|
  prt cmd.help
  exit 0
end

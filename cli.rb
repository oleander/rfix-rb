require "cri"
# Cri::Command.load_file('commands/check.rb')

command = Cri::Command.define do
  name        'dostuff'
  usage       'dostuff [args]'
  aliases     :ds, :stuff
  summary     'does stuff'
  description 'This command does a lot of stuff, but not option parsing.'

  skip_option_parsing
  flag :q, :quick, 'publish quicker'
  # param :filename


  run do |opts, args, cmd|
    pp opts
    puts args.inspect

    pp ARGV
  end
end

pp command.run(ARGV)

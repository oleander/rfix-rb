# frozen_string_literal: true

extend Rfix::Log

flag   :h,  :help, "show help for this command" do |_value, cmd|
  prt cmd.help
  exit 0
end

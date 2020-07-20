r_args = []

helper("help", binding)

summary "This is how you get started with {{command:rfix}}"

run do |_opts, _args, _cmd|
  indent = " " * 2
  prt "{{v}} Thank you for installing {{green:rfix v#{Rfix::VERSION}}}!\n"
  prt ""
  prt "{{i}} Run {{command:rfix help}} for avalible commands or any of the following to get started:"
  prt ""
  prt "#{indent}{{command:$ rfix local}}   {{italic:# Auto-fixes commits not yet pushed to upstream}}"
  prt "#{indent}{{command:$ rfix origin}}  {{italic:# Auto-fixes commits between HEAD and origin branch}}"
  prt "#{indent}{{command:$ rfix lint}}    {{italic:# Lints commits and untracked files not yet pushed to upstream}}"
  prt ""
  prt "{{*}} {{bold:ProTip:}} Append {{command:--dry}} to run {{command:rfix}} in {{warning:read-only}} mode"
  prt ""
  prt "{{i}} {{bold:Issues}} {{italic:https://github.com/oleander/rfix-rb/issues}}"
  prt "{{i}} {{bold:Readme}} {{italic:https://github.com/oleander/rfix-rb/blob/master/README.md}}"
  prt "{{i}} {{bold:Travis}} {{italic:https://travis-ci.org/github/oleander/rfix-rb}}"
  prt ""
  prt "{{italic:~ Linus}}\n"
end

# helper("help", binding)
# helper("rubocop", binding)
# helper("args", binding)
#
# summary "All"
#
# run do |opts, args, cmd|
#   setup(opts, args) do |repo, files|
#     q1 = "Are you sure you want to {{warning:auto-fix}} the {{warning:the entire folder}}"
#     q2 = "Are you sure you want to {{warning:auto-fix}} everything in {{warning:#{files.join(", ")}?}}"
#
#     begin
#       if files.empty?
#         unless CLI::UI.confirm(q1)
#           exit 1
#         end
#       elsif CLI::UI.confirm(q2)
#         exit 1
#       end
#     rescue Interrupt
#       exit 1
#     end
#
#     Rfix.global_enable!
#   end
# end

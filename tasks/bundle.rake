# namespace :bundle do
#   gemfiles = Rake::FileList.new("Gemfile*", "ci/Gemfile*") do |rule|
#     rule.exclude("*.lock")
#   end
#
#
#   task install: gemfiles
#
#   # task :default => :install
#   # rule ".html" => ->(f){ FileList[f.ext(".*")].first } do |t|
#   #   sh "pygmentize -o #{t.name} #{t.source}"
#   # end
#
#   rule ".lock" => gemfiles do |t|
#     say "OKay"
#     sh "bundle", "install", "--gemfile", t.source
#   end
# end

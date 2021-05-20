require "bundler"
require "bundler/setup"

Bundler.require

require "rugged"
require "rfix"

repo = Rugged::Repository.discover

file = "examples/test.rb"

repo.status(file) do |path, statuses|
  puts "STATUS: #{path}, #{statuses}"
end

origin = repo.lookup("f9e099da61ae3742bed3e9b2a73e9cd069d97f48")
options = Rfix::Collector::OPTIONS.merge(paths: [file])

origin.diff_workdir(**options).each_delta do |delta|
  delta.new_file.fetch(:path).then do |file_path|
    puts "Delta: #{file_path}, #{delta.status}"
  end
end



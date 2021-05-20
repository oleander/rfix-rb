# frozen_string_literal: true

require "bundler"
require "bundler/setup"

Bundler.require

require "rugged"
require "tmpdir"
require "rfix"

dummy_path = Pathname(Dir.mktmpdir)

path = dummy_path.to_s

def git(*args)
  system "git", *args.map(&:to_s)
end

def add(path)
  git(:add, path)
end

def commit(msg = "msg")
  git(:commit, "-am", msg)
end

def track(file)
  add(file)
  commit
end

tracked = dummy_path.join("tracked.rb")
untracked = dummy_path.join("untracked.rb")
staged = dummy_path.join("staged.rb")
unstaged = dummy_path.join("unstaged.rb")
ignored = dummy_path.join("ignored.rb")
gitignore = dummy_path.join(".gitignore")
moved = dummy_path.join("moved.rb")
moved_new = dummy_path.join("moved.new.rb")
out_of_range = dummy_path.join("out-of-range.rb")
tracked_deleted = dummy_path.join("tracked_deleted.rb")

origin = nil
repo = Rugged::Repository.init_at(dummy_path)
Dir.chdir(dummy_path) do
  3.times do |n|
    out_of_range.write("# NOP: #{n}")
    add(out_of_range)
    commit
  end

  origin = repo.head.target

  tracked.write("# NOP")
  track(tracked)

  puts origin.oid
  untracked.write("# NOP more")

  staged.write("# NOP more")
  add(staged)

  unstaged.write("# NOP more 1")
  add(staged)
  commit("add tracked file")
  unstaged.write("# NOP more 2")

  ignored.write("# Ignored!")
  gitignore.write(ignored.basename.to_s)

  moved.write("# ruby")
  track(moved)
  git(:mv, moved, moved_new)

  tracked_deleted.write("# ruby")
  track(tracked_deleted)
  tracked_deleted.delete
end

# dummy_path = Pathname(__dir__).join("dummy")
puts repo.workdir

# repo.status do |path, statuses|
#   puts "STATUS: #{path}, #{statuses}"
# end

# walker = Rugged::Walker.new(repo)
# walker.sorting(Rugged::SORT_TOPO | Rugged::SORT_REVERSE)
# walker.push("HEAD")

# unless oid = walker.each_oid(limit: 1).first
#   abort "Repository contains no commits"
# end

# origin = repo.lookup(oid)
# options = Rfix::Collector::OPTIONS.dup.merge(include_untracked: false)
options = {}.dup.merge(
  context_lines: 1,
  ignore_whitespace: true,
  ignore_whitespace_change: true,
  ignore_whitespace_eol: true,
  disable_pathspec_match: true,
  ignore_submodules: true,
  include_ignored: false,
  include_unmodified: false,
  include_untracked_content: false,
  include_typechange: false
)

diff = origin.diff(repo.index, **options)
diff.merge!(repo.index.diff(**options))
diff.find_similar!(all: true, ignore_whitespace: true)

rejections = %i[deleted? ignored? renamed? typechange? copied?]
selection = %i[added? modified?]

deltas = diff.deltas

$repo = repo

def info(delta)
  puts "%s (%s) <%s>" % [delta.new_file.fetch(:path), delta.status, $repo.status(delta.new_file[:path])]
end

puts "Before: "
deltas.map do |delta|
  info(delta)
end
puts "----------------"
puts "After: "
require "active_support/all"
result = deltas.select do |delta|
  %i[added modified untracked].include?(delta.status)
end

result.map do |delta|
  puts "%s (%s)" % [delta.new_file.fetch(:path), delta.status]
end

# .each_delta do |delta|
#   delta.new_file.fetch(:path).then do |file_path|
#     puts "Delta: #{file_path}, #{delta.status}"
#   end
# end

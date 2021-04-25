# frozen_string_literal: true

require "rugged"
repo = Rugged::Repository.discover

repo.head.target.diff.tap do |diff|
  diff.find_similar!(
    renames_from_rewrites: true,
    renames: true,
    copies: true
  )
end.each_delta.map do |delta|
  p delta.new_file
  p delta.status
  puts "------------"
end

repo.status do |file|
  p file
end

# index_modified
# git add <file>

# changed worktree_modified

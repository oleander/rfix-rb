require "rugged"
require "fileutils"
require "rainbow"
require "tmpdir"
require "rfix"
require 'shellwords'
require "set"

extend Rfix::Log

# root_path = Dir.mktmpdir
# at_exit { FileUtils.remove_dir(root_path) }


# Dir.chdir(root_path) do
#   File.write(".gitignore", "# empty")
#   system "git init"
#   system "git add .gitignore"
#   system "git commit -a -m 'Test'"
# end


# class Git
#
#   class Blob < Struct.new(:repo, :tree)
#     def commit(msg)
#       author = {:email=>"tanoku@gmail.com", :time=>Time.now, :name=>"Vicent Mart\303\255"}
#
#       Rugged::Commit.create(repo,
#       	:author => author,
#       	:message => msg,
#       	:committer => author,
#       	:parents => parents,
#       	:tree => tree,
#       	:update_ref => "HEAD")
#     end
#
#     def parents
#       repo.empty? ? [] : [ repo.head.target ].compact
#     end
#   end
#
#   attr_reader :repo
#
#   def initialize(root_path)
#     @repo = Rugged::Repository.new(root_path)
#     # @repo.index.read_tree(@repo.head.target.tree)
#     # @repo.index.reload
#     # @repo.index.write_tree(@repo)
#   end
#
#   def blob(params)
#     abort "Must be a hash" unless params.is_a?(Hash)
#     debug("New blob")
#     index = repo.index
#     index.reload
#
#     params.each do |path, content|
#       oid = repo.write(content, :blob)
#       index.read_tree(repo.head.target.tree)
#       index.add(path: path, oid: oid, mode: 0100644)
#     end
#
#     Blob.new(repo, index.write_tree(repo))
#   end
#
#   def has_branch?(name)
#     repo.branches.each_name().include?(name)
#   end
#
#   def branch(name)
#     debug("Checkout branch #{name}")
#     if branch = repo.branches[name]
#       return repo.checkout(branch)
#     end
#
#     repo.create_branch(name)
#   end
#
#   def tag(name)
#     debug("Add tag #{name}")
#     repo.tags.create(name, "HEAD")
#   end
#
#   def checkout(ref)
#     debug "Checkout ref #{ref}"
#     repo.checkout(ref)
#   end
#
#   def status
#     debug "-- Get status"
#     repo.status do |file, status|
#       say "#{file} => #{status}"
#     end
#
#     repo.index.entries.each do |entry|
#       say "Staged: #{entry}"
#     end
#     debug "-- End of status"
#   end
#
#   def say(msg)
#     puts Rainbow("[LOG]").blue + " #{msg}"
#   end
#
#   def debug(msg)
#     puts Rainbow("[DEBUG]").red + " #{msg}"
#   end
#
#   def new_file(file, content)
#     debug "New file #{file}"
#     Dir.chdir(repo.workdir) do
#       File.write(file, content)
#     end
#
#     file
#   end
#
#   def add(file)
#     debug "Add file #{file}"
#     index = Rugged::Index.new(file)
#     index.write_tree(repo)
#     Blob.new(repo, index.write_tree(repo))
#   end
# end

# repo = Git.new(root_path)
# repo.status
# puts "------"
# repo.branch("master")
# repo.tag("v2")
# repo.branch("mastsdkfjfsd")
# repo.blob("example.rb" => "This is content").commit("This is my message")
# repo.status
# repo.checkout("v2")
# repo.blob("valid.rb" => "This is content")
# .commit("This is my message")
# repo.blob("this.rb" => "This is content").commit("This is my message")
# file = repo.new_file("valid.rb", "this is content")
# repo.status
# blob = repo.add(file)
# repo.status
# puts "----"
# blob.commit("Okay!")
# repo.status

class AFile
  include Rfix::Log
  attr_reader :repo, :path

  def initialize(path, repo)
    @repo = repo
    @path = Shellwords.escape(path)
    refresh!
  end

  def include?(line)
    return true unless @changes
    @changes.include?(line)
  end

  def refresh!
    @changes = changed_lines
  rescue Rugged::TreeError
    @changed = nil
  end

  private

  def upstream
    @repo.rev_parse("@{u}:#{@path}")
  end

  def head
    @repo.rev_parse("HEAD:#{@path}")
  end

  def diff
    upstream.diff(head)
  end

  def changed_lines
    diff.each_hunk
      .to_a
      .map(&:lines)
      .flatten
      .map(&:new_lineno)
      .to_set
  end
end

repo = Rugged::Repository.new(".")
files = `git ls-tree -r master --name-only`.lines.map(&:chomp)

result = files.each_with_object({}) do |path, acc|
  acc[path] = AFile.new(path, repo)
end

pp result

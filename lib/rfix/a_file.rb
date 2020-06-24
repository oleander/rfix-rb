require "rugged"
require "shellwords"

class AFile
  include Rfix::Log
  attr_reader :repo, :path

  def initialize(path, repo, ref)
    @repo = repo
    @ref = ref
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
    abort "Ref not set" unless @ref
    @repo.rev_parse("#{@ref}:#{@path}")
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

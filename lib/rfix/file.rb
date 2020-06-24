require "rugged"
require "shellwords"

class Rfix::Error < StandardError
end

class Rfix::File < Struct.new(:path, :repo, :ref)
  include Rfix::Log

  def initialize(path, repo, ref)
    super(File.join(repo.workdir, path), repo, ref)
  end

  def include?(_)
    raise Rfix::Error.new("#include? not implemented")
  end

  def refresh!
    raise Rfix::Error.new("#refresh! not implemented")
  end

  def inspect
    raise Rfix::Error.new("#inspect not implemented")
  end

  def git_path
    @git_path ||= Pathname.new(repo.workdir)
  end

  def relative_path
    @relative_path ||= git_path.relative_path_from(Pathname.new(path)).to_s
  end
end

class Rfix::Untracked < Rfix::File
  def include?(_)
    return true
  end

  def refresh!
    # NOP
  end

  def inspect
    "<Untracked({{info:#{relative_path}}})>"
  end
end

class Rfix::Tracked < Rfix::File
  class NoFile < Struct.new(:path)
    def include?(_)
      return true
    end

    def divide
      Set.new
    end
  end

  def include?(line)
    unless has_changes?
      return refresh!.include?(line)
    end

    return changes.include?(line)
  end

  def refresh!
    @changes = diff.each_hunk.to_a.map(&:lines).flatten.map(&:new_lineno).to_set
  rescue Rugged::TreeError
    @changed = NoFile.new(path)
  ensure
    return self
  end

  private

  def has_changes?
    !@changes.nil?
  end

  def escaped_path
    @escaped_path ||= Shellwords.escape(path)
  end

  def upstream
    repo.rev_parse("#{ref}:#{escaped_path}")
  end

  def head
    repo.rev_parse("HEAD:#{escaped_path}")
  end

  def diff
    upstream.diff(head)
  end

  def changes
    return @changes if @changes.is_a?(Set)
    return refresh!.chanages if @changed.nil?
    return @changes if @changes.is_a?(NoFile)
    say_abort "Invalid type of #{@changes}"
  end

  def line_numbers
    changes.divide do |i,j|
      (i - j).abs == 1
    end.each.to_a.map(&:to_a).map do |set|
      "#{set.first}:#{set.last}"
    end.join(", ")
  end

  def inspect
    if changes.is_a?(NoFile)
      return wrapper(relative_path)
    end

    wrapper("#{relative_path}[#{line_numbers}]")
  end

  def wrapper(msg)
    return "<Tracked({{info:#{msg}}})>"
  end
end

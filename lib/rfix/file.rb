require "rugged"
require "shellwords"

class Rfix::Error < StandardError
end

class Rfix::File < Struct.new(:path, :repo, :ref)
  include Rfix::Log

  alias == eql?

  def initialize(path, repo, ref)
    if Pathname.new(path).absolute?
      say_abort "Path must be relative #{path}"
    end

    @path_cache = {}
    super(path, repo, ref)
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

  def hash
    normalized_path.hash
  end

  def eql?(other)
    case other
    when Rfix::File
      return normalized_path == other.normalized_path
    when String
      return normalized_path == normalize_path(other)
    else
      raise Rfix::Error.new("Cannot compare #{self} with #{other}")
    end
  end

  def normalized_path
    @normalize_path ||= normalize_path(absolute_path)
  end

  def absolute_path
    @absolute_path ||= to_abs(path)
  end

  def to_abs(path)
    File.join(repo.workdir, path)
  end

  private

  def normalize_path(path)
    if cached = @path_cache[path]
      return cached
    end

    if Pathname.new(path).absolute?
      @path_cache[path] = File.realdirpath(path)
    else
      @path_cache[path] = File.realdirpath(to_abs(path))
    end
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
    say_error $!
    @changed = NoFile.new(path)
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

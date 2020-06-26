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

  def absolute_path
    @absolute_path ||= to_abs(path)
  end

  def to_abs(path)
    File.join(repo.workdir, path)
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
    "<Untracked({{info:#{path}}})>"
  end
end

class Rfix::Tracked < Rfix::File
  include Rfix::Log
  class NoFile < Struct.new(:path)
    def include?(line)
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
    @changes = diff.each_line.to_a.map(&:new_lineno).to_set
  rescue Rugged::TreeError
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
    repo.rev_parse(ref)
  end

  def head
    repo.rev_parse("HEAD")
  end


  # https://github.com/libgit2/rugged/blob/f8172c2a177a6795553f38f01248daff923f4264/lib/rugged/tree.rb
  def diff
    repo.diff_workdir(upstream, { recurse_untracked_dirs: true, context_lines: 0, include_ignored: false, include_untracked: true, include_untracked_content: true, ignore_whitespace: true, ignore_whitespace_change: true, ignore_whitespace_eol: true, ignore_submodules: true, paths: [path], disable_pathspec_match: true})
  end

  def changes
    if @changes.is_a?(Set)
      if @changes.empty?
        return NoFile.new(path)
      else
        return @changes
      end
    end

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
      return wrapper(path)
    end

    wrapper("#{path}[#{line_numbers}]")
  end

  def wrapper(msg)
    return "<Tracked({{info:#{msg}}})>"
  end
end

require "rfix/no_file"

class Rfix::Tracked < Rfix::File
  include Rfix::Log

  def include?(line)
    refresh! if needs_update?
    changes.include?(line)
  end

  private

  def refresh!
    @changes = diff.each_line.to_a.map(&:new_lineno).to_set

    if @changes.empty?
      @changes = NoFile.new(path)
    end
  rescue Rugged::TreeError
    @changed = NoFile.new(path)
  end

  def changes
    @changes or raise(Rfix::Error, "No changes found: #{self}")
  end

  def needs_update?
    current_changed_at = changed_at
    if @changed_at != current_changed_at
      @changed_at = current_changed_at
      return true
    end

    return false
  end

  def changed_at
    File.new(absolute_path).ctime
  end

  def upstream
    repo.rev_parse(ref)
  end

  # https://github.com/libgit2/rugged/blob/f8172c2a177a6795553f38f01248daff923f4264/lib/rugged/tree.rb
  def diff
    repo.diff_workdir(upstream, { recurse_untracked_dirs: true, context_lines: 0, include_ignored: false, include_untracked: true, include_untracked_content: true, ignore_whitespace: true, ignore_whitespace_change: true, ignore_whitespace_eol: true, ignore_submodules: true, paths: [path], disable_pathspec_match: true })
  end

  def line_numbers
    changes.divide do |i, j|
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

require "rfix/no_file"

module Rfix
  class Tracked < File
    include Log

    def include?(line)
      set = diff.each_line.to_a.map(&:new_lineno).reject { |l| l == -1 }.to_set
      say_debug "Does {{yellow:#{set}}} contain {{red:#{line}}}"
      set.include?(line)
    end

    private

    # def set
    #   return NoFile.new(path) if @set.empty?
    #   return @set
    # end

    # def refresh!
    #   @changes = diff.each_line.to_a.map{ |l| l.new_lineno }.to_set
    #
    #   if @changes.empty?
    #     @changes = NoFile.new(path)
    #   end
    # rescue Rugged::TreeError
    #   @changed = NoFile.new(path)
    # end

    # def changes
    #   @changes or raise(Error, "No changes found: #{self}")
    # end

    # def needs_update?
    #   current_changed_at = changed_at
    #   if @changed_at != current_changed_at
    #     @changed_at = current_changed_at
    #     return true
    #   end
    #
    #   return false
    # end

    # def changed_at
    #   File.new(absolute_path).ctime
    # end

    def upstream
      @upstream ||= ref.resolve(with: repo)
    end

    def head
      @head ||= repo.rev_parse("HEAD")
    end

    def diff
      upstream.diff_workdir({
                              include_untracked_content: true,
        recurse_untracked_dirs: true,
        include_untracked: true,
        ignore_submodules: true,
        include_ignored: false,
        context_lines: 0,
        paths: [path]
                            }).tap do |diff|
        diff.find_similar!(
          renames_from_rewrites: true,
          renames: true,
          copies: true
        )
      end
    end
  end
end

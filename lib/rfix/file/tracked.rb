module Rfix
  module File
    class Tracked < Base
      attribute :status, Types::Symbol.enum(*TRACKED)

      def include?(line:)
        set = diff.each_line.to_a.map(&:new_lineno).reject { |l| l == -1 }.to_set
        set.include?(line)
      end

      def upstream
        @upstream ||= ref.resolve(with: repository)
      end

      def head
        @head ||= repository.head.target
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
end

# frozen_string_literal: true

module Rfix
  module File
    class Tracked < Base
      attribute :status, Types.Value([:added])

      def include?(line:)
        diff.each_line.to_a.map(&:new_lineno).reject do |line|
          line == -1
        end.to_set.include?(line)
      end

      def refresh!
        # NOP
      end

      def tracked?
        true
      end

      private

      def upstream
        @upstream ||= repository.rev_parse("@{upstream}")
      end

      def diff
        upstream.diff_workdir({
          include_untracked_content: true,
          recurse_untracked_dirs: true,
          include_untracked: true,
          ignore_submodules: true,
          include_ignored: false,
          context_lines: 0,
          paths: [path.to_s]
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

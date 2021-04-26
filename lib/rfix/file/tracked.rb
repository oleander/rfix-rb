# frozen_string_literal: true

module Rfix
  module File
    class Tracked < Base
      attribute :status, Types::Status::Tracked

      OPTIONS = {
        include_untracked_content: true,
        recurse_untracked_dirs: true,
        include_untracked: true,
        ignore_submodules: true,
        include_ignored: false,
        context_lines: 0
      }.freeze

      def include?(line)
        diff.each_line.map(&:new_lineno).to_set.include?(line)
      end

      def tracked?
        true
      end

      private

      def options
        OPTIONS.dup.merge(paths: [basename])
      end

      def diff
        repository.diff_workdir(repository.origin, **options).tap do |diff|
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

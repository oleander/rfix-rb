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

      def include?(line:)
        diff.each_line.map(&:new_lineno).to_set.include?(line)
      end

      def refresh!
        # NOP
      end

      def tracked?
        true
      end




      private

      def diff
        repository.diff_workdir(repository.head.target, **OPTIONS.dup.merge(paths: [basename]))
      end
    end
  end
end

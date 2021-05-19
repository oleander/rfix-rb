# frozen_string_literal: true
require "pry"
module Rfix
  module File
    class Tracked < Base
      attribute :status, Types::Status::Tracked.default(TRACKED)

      delegate :include?, to: :lines

      def tracked?
        true
      end

      def to_s
        [basename.to_path, to_str_range].join(":")
      end

      def to_str_range
        lines
          .chunk_while { |i, j| i + 1 == j }
          .map { |a| a.length < 3 ? a : "#{a.first}-#{a.last}" }
          .join(",")
          .then { |res| res.empty? ? "-" : res }
      end

      def to_table
        [basename, to_str_range]
      end

      def lines
        diff.each_line.map(&:new_lineno).select(&:positive?)
      end

      private

      def options
        Collector::OPTIONS.dup.merge(paths: [basename.to_path])
      end

      def diff
        repository.origin.diff_workdir(**options).tap do |diff|
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

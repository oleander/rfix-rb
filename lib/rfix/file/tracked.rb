# frozen_string_literal: true

require "rainbow/ext/string"

module Rfix
  module File
    class Tracked < Base
      ID = "[T]".color(:lightseagreen).freeze

      attribute :status, Types::Status::Tracked.default(TRACKED)
      attribute :cache, Types.Instance(Concurrent::Map).default { Concurrent::Map.new }

      delegate :include?, to: :lines

      def tracked?
        true
      end

      def to_s
        "%s:%s" % [basename, to_str_range]
      end

      def to_str_range
        lines
          .sort
          .chunk_while { |i, j| i + 1 == j }
          .map { |a| a.length < 3 ? a : "#{a.first}-#{a.last}" }
          .to_a
          .join(",")
          .then { |res| res.empty? ? "-" : res }
      end

      def to_table
        [basename, to_str_range]
      end

      def lines
        diff.each_line.lazy.map(&:new_lineno).select(&:positive?)
      end

      private

      def options
        Collector::OPTIONS.merge(paths: [basename.to_path])
      end

      def diff
        repository.origin.diff_workdir(**options).tap do |diff|
          # diff.merge!(repository.index.diff(**options))
        end
      end
    end
  end
end

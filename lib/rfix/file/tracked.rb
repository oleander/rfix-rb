# frozen_string_literal: true

require "rainbow/ext/string"

module Rfix
  module File
    class Tracked < Dry::Struct
      ID = "[T]".color(:lightseagreen).freeze

      attribute :status, Types::Symbol
      attribute :path, Types::Path::Relative
      attribute :repository, Repository

      delegate :include?, to: :lines

      def key
        path.to_s
      end

      def exists?
        true
      end

      def tracked?
        true
      end

      def to_s
        "%s:%s" % [path, to_str_range]
      end

      def to_str_range
        lines
          .to_a
          .sort
          .chunk_while { |i, j| i + 1 == j }
          .map { |a| a.length < 3 ? a : "#{a.first}-#{a.last}" }
          .to_a
          .join(",")
          .then { |res| res.empty? ? "-" : res }
      end

      def to_table
        [path, to_str_range]
      end

      def lines
        Diff.new(repository: repository, options: {
          paths: [path.to_path]
        }).lines.lazy.map(&:new_lineno).select(&:positive?)
      end
    end
  end
end

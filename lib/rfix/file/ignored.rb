# frozen_string_literal: true

module Rfix
  module File
    class Ignored < Base
      ID = "[I]".color(:blue).freeze

      attribute :status, Types::Status::Ignored

      def include?(*)
        false
      end

      def ignored?
        true
      end
    end
  end
end

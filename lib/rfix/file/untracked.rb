# frozen_string_literal: true

require "dry/types"
require "rainbow/ext/string"

module Rfix
  module File
    class Untracked < Base
      ID = "[U]".color(:palevioletred)

      attribute :status, Types::Status::Untracked

      def untracked?
        true
      end

      def include?(*)
        true
      end
    end
  end
end

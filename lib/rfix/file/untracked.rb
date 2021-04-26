# frozen_string_literal: true

require "dry/types"

module Rfix
  module File
    class Untracked < Base
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

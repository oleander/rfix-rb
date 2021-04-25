# frozen_string_literal: true

module Rfix
  class Deleted < File
    def include?(_)
      false
    end

    def refresh!
      # NOP
    end

    def inspect
      "<Deleted({{info:#{path}}})>"
    end
  end
end

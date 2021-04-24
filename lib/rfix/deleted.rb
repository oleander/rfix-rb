module Rfix
  class Deleted < File
    def include?(_)
      return false
    end

    def refresh!
      # NOP
    end

    def inspect
      "<Deleted({{info:#{path}}})>"
    end
  end
end

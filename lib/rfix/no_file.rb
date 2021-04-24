module Rfix
  class NoFile < Struct.new(:path)
    def include?(_line)
      return true
    end

    def divide
      Set.new
    end

    def empty?
      false
    end
  end
end

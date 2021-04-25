# frozen_string_literal: true

module Rfix
  NoFile = Struct.new(:path) do
    def include?(_line)
      true
    end

    def divide
      Set.new
    end

    def empty?
      false
    end
  end
end

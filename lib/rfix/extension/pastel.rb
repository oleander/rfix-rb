require "pastel"

module Pastel
  class Color
    def strip(*strings)
      modified = strings.map(&Strings::ANSI.method(:sanitize))
      modified.size == 1 ? modified[0] : modified
    end
  end
end

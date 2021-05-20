# frozen_string_literal: true

require "pastel"
require "strings"

module Pastel
  class Color
    concerning :Fallback, prepend: true do
      def strip(*strings)
        super(*strings.map(&Strings::ANSI.method(:sanitize)))
      end
    end
  end
end

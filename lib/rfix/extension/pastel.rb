# frozen_string_literal: true

require "pastel"
require "strings"

module Rfix
  module Extension
    module Pastel
      def strip(*strings)
        modified = strings.map(&::Strings::ANSI.method(:sanitize))
        modified.size == 1 ? modified[0] : modified
      end
    end
  end
end

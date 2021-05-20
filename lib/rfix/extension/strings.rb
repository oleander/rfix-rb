# frozen_string_literal: true

require "strings"

module Strings
  module Wrap
    concerning :Fallback, prepend: true do
      class_methods do
        def wrap(line, *, **)
          super
        rescue IndexError
          line
        end
      end
    end
  end
end

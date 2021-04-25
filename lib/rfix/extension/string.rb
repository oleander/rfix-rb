# frozen_string_literal: true

# TODO: Use refinements instead
module Rfix
  module Extension
    class String
      def fmt
        Log.fmt self
      end
    end
  end
end

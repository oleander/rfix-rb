# frozen_string_literal: true

module Rfix
  module Extension
    module Option
      def define_options
        @define_options ||= super
      end
      alias opts define_options
    end
  end
end

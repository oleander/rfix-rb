# frozen_string_literal: true

module Rfix
  module Extension
    class CommentConfig < RuboCop::CommentConfig
      def cop_enabled_at_line?(_, line)
        Rfix.enabled?(processed_source.file_path, line) && super
      end
    end
  end
end

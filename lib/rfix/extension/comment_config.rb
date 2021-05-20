# frozen_string_literal: true

require "rubocop"

module RuboCop
  class CommentConfig
    concerning :Fallback, prepend: true do
      def cop_enabled_at_line?(_, line)
        super && repository.include?(processed_source.file_path, line)
      rescue StandardError => e
        abort e.full_message(highlight: true)
      end
    end
  end
end

# frozen_string_literal: true

module Rfix
  module Extension
    module CommentConfig
      def cop_enabled_at_line?(_, line)
        super && repository.include?(processed_source.file_path, line)
      rescue StandardError => e
        abort e.full_message(highlight: true)
      end
    end
  end
end

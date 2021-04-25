# frozen_string_literal: true

module Rfix
  class TrackedFile < GitFile
    def refresh!
      @ranges = git("--no-pager", "diff", *params, "#{ref}..HEAD", path)
                .grep(/^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@/) do
        Regexp.last_match(1).to_i...(Regexp.last_match(1).to_i + (Regexp.last_match(2) || 1).to_i)
      end
    end

    def include?(line:)
      @ranges.any? { |range| range.include?(line) }
    end
  end
end

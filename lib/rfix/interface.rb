# frozen_string_literal: true

module Rfix
  module Interface
    include Log

    def global_enable!
      @global_enable = true
    end

    def test?
      test
    end

    def global_enable?
      @global_enable
    end

    def refresh!(source)
      return true if global_enable?

      repo.refresh!(source.file_path)
    end

    def enabled?(path, line)
      return true if global_enable?

      repo.include?(path, line)
    end
  end
end

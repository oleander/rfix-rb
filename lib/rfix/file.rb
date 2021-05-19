# frozen_string_literal: true

module Rfix
  module File
    def self.sum
      Deleted | Ignored | Tracked | Untracked
    end

    class << self
      delegate :call, to: :sum
    end
  end
end

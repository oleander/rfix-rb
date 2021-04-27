# frozen_string_literal: true

module Rfix
  module Branch
    class Head < Base
      def resolve
        repository.lookup(repository.head.target_id)
      end

      def to_s
        "HEAD"
      end
    end
  end
end

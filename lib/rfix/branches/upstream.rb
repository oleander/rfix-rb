require_relative "base"

module Rfix
  class Branch::Upstream < Branch::Base
    def resolve(with:)
      with.rev_parse("@{upstream}")
    end

    def to_s
      "upstream"
    end
  end
end

module Rfix
  class Branch::Head < Branch::Base
    def resolve(with:)
      with.lookup(with.head.target_id)
    end

    def to_s
      "HEAD"
    end
  end
end

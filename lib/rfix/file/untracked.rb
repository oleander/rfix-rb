module Rfix
  module File
    class Untracked < Ignored
      attribute :status, Types::Symbol.enum(*UNTRACKED)
    end
  end
end

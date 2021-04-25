require "dry/types"

module Rfix
  module Types
    include Dry::Types()

    Rugged = Instance(Rugged::Repository)
  end
end

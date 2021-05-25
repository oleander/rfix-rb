# frozen_string_literal: true

require "concurrent/map"
require "dry/types"

map = Concurrent::Map.new do |map, key|
  map.fetch(Dry::Types["coercible.string"].call(key), nil)
end

# pp map[:key]
map["key"] = "vbalue"
pp map["key"]
pp map["that"]
pp map["that"]
pp map[:key]

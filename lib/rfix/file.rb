# frozen_string_literal: true

require "pathname"
require "dry/struct/union"

module Rfix
  module File
    include Dry::Struct::Union
  end
end

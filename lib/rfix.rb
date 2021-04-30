# frozen_string_literal: true

require "active_support/core_ext/module/attribute_accessors"
require "zeitwerk"
require "rubocop"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/rfix/rake")
loader.ignore("#{__dir__}/rfix/loader")
loader.ignore("#{__dir__}/rfix/commands")
loader.inflector.inflect "cli" => "CLI"

loader.setup

module Rfix
  mattr_accessor :repo, :test
end

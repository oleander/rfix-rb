# frozen_string_literal: true

require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/module/concerning"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem

loader.ignore("#{__dir__}/rfix/rake/support")
loader.ignore("#{__dir__}/rfix/rake/paths")
loader.ignore("#{__dir__}/rfix/extension")
loader.ignore("#{__dir__}/rfix/commands")
loader.ignore("#{__dir__}/rfix/rake")

loader.inflector.inflect "cli" => "CLI"

# Lazy ...
loader.on_load("Rfix::Formatter") do
  Pathname(__dir__).glob("rfix/extension/*", &method(:require))
end

loader.setup

module Rfix
  mattr_accessor :repo, :test
end

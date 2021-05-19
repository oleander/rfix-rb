# frozen_string_literal: true

require "active_support/core_ext/module/attribute_accessors"
require "rfix/extension/offense"
require "zeitwerk"
require "rubocop"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/rfix/rake/paths")
loader.ignore("#{__dir__}/rfix/rake/support")
loader.ignore("#{__dir__}/rfix/loader")
loader.ignore("#{__dir__}/rfix/rake")
loader.ignore("#{__dir__}/rfix/commands")
loader.ignore("#{__dir__}/rfix/extension")
loader.inflector.inflect "cli" => "CLI"
loader.setup

module Rfix
  mattr_accessor :repo, :test
end

Rfix.define_singleton_method(:reload) do
  loader.reload
end

RuboCop::Cop::Offense.prepend(Rfix::Extension::Offense)

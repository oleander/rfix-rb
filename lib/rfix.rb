# frozen_string_literal: true

require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/module/concerning"
require "zeitwerk"
require "rubocop"

Dir["rfix/extension/**/*"].sort.each(&method(:require))

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/rfix/rake/paths")
loader.ignore("#{__dir__}/rfix/rake/support")
loader.ignore("#{__dir__}/rfix/loader")
loader.ignore("#{__dir__}/rfix/rake")
loader.ignore("#{__dir__}/rfix/extension")
loader.ignore("#{__dir__}/rfix/commands")
loader.inflector.inflect "cli" => "CLI"
loader.setup

module Rfix
  mattr_accessor :repo, :test
end

require "rfix/extension/offense"
RuboCop::Cop::Offense.prepend(Rfix::Extension::Offense)

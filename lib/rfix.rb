# frozen_string_literal: true

require "active_support/core_ext/module/concerning"
require "active_support/core_ext/module/attribute_accessors"
require "zeitwerk"
require "rubocop"
require "pastel"

require "rfix/extension/strings"
require "rfix/extension/pastel"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/rfix/rake/paths")
loader.ignore("#{__dir__}/rfix/rake/support")
loader.ignore("#{__dir__}/rfix/loader")
loader.ignore("#{__dir__}/rfix/rake")
loader.ignore("#{__dir__}/rfix/extension/strings")
loader.ignore("#{__dir__}/rfix/extension/pastel")
loader.ignore("#{__dir__}/rfix/commands")
loader.inflector.inflect "cli" => "CLI"
loader.setup

module Rfix
  mattr_accessor :repo, :test
end

RuboCop::CommentConfig.prepend(Rfix::Extension::CommentConfig)
RuboCop::Cop::Offense.prepend(Rfix::Extension::Offense)

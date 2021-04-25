# frozen_string_literal: true

require "active_support/core_ext/module/attribute_accessors"
require "zeitwerk"
require "rubocop"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/rfix/rake")
loader.ignore("#{__dir__}/rfix/loader")
loader.ignore("#{__dir__}/rfix/commands")

loader.on_load("Rfix::Formatter") do
  require "cli/ui"

  CLI::UI::StdoutRouter.enable

  # TODO: Handle cases where color can't be resolved by CLI::UI
  RuboCop::Formatter::SimpleTextFormatter::COLOR_FOR_SEVERITY.each do |severity, color|
    id = RuboCop::Cop::Severity::CODE_TABLE.invert.fetch(severity)
    CLI::UI::Glyph.new(id.to_s, 0x25cf, "<G>", CLI::UI.resolve_color(color))
  end
end

loader.setup

module Rfix
end

loader.eager_load

module Rfix
  include Interface
end

module Rfix
  RuboCop::CommentConfig.prepend(Extension::CommentConfig)
  RuboCop::Cop::Offense.prepend(Extension::Offense)
  RuboCop::Options.prepend(Extension::Option)
end

# frozen_string_literal: true

require "active_support/core_ext/module/attribute_accessors"
require "zeitwerk"
require "rubocop"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/rfix/rake")
loader.ignore("#{__dir__}/rfix/loader")
loader.ignore("#{__dir__}/rfix/commands")

loader.on_load("Rfix::Formatter") do
  RuboCop::Options.prepend(Rfix::Extension::Option)
end

["Rfix::Formatter", "Rfix::Highlighter", "Rfix::Log"].each do |name|
  loader.on_load(name) do
    @loaded ||= begin
      require "cli/ui"

      CLI::UI::StdoutRouter.enable

      # TODO: Handle cases where color can't be resolved by CLI::UI
      RuboCop::Formatter::SimpleTextFormatter::COLOR_FOR_SEVERITY.each do |severity, color|
        id = RuboCop::Cop::Severity::CODE_TABLE.invert.fetch(severity)
        CLI::UI::Glyph.new(id.to_s, 0x25cf, "<G>", CLI::UI.resolve_color(color))
      end
    end
  end
end

loader.setup

module Rfix
  include Interface

  mattr_accessor :repo, :test
  module_function :enabled?, :refresh!, :global_enable?, :test?, :global_enable!
end

#!/usr/bin/env ruby
# frozen_string_literal: true

# https://gist.github.com/skanev/9d4bec97d5a6825eaaf6

require "rfix/version"
require "cli/ui"
require "rfix/extensions/extensions"
require "rfix/extensions/offense"
require "rfix/rfix"

module Rfix
  module Ext; end
  extend self
end

RuboCop::Options.prepend(Rfix::Ext::Options)
RuboCop::Runner.prepend(Rfix::Ext::Runner)
RuboCop::CommentConfig.prepend(Rfix::Ext::CommentConfig)
RuboCop::Cop::Offense.prepend(Rfix::Ext::Offense)

# TODO: Handle cases where color can't be resolved by CLI::UI
RuboCop::Formatter::SimpleTextFormatter::COLOR_FOR_SEVERITY.each do |severity, color|
  id = RuboCop::Cop::Severity::CODE_TABLE.invert.fetch(severity)
  CLI::UI::Glyph.new(id.to_s, 0x25cf, CLI::UI.resolve_color(color))
end

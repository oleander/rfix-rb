#!/usr/bin/env ruby
# frozen_string_literal: true

# https://gist.github.com/skanev/9d4bec97d5a6825eaaf6

require "cli/ui"
require "rfix/version"
require "rfix/log"
require "rfix/cmd"
require "rfix/repository"
require "rfix/formatter"
require "rfix/extensions/extensions"
require "rfix/extensions/offense"
require "rfix/branch"
require "rfix/rfix"
require "rfix/box"
require "rfix/error"

module Rfix
  module Ext; end
  extend self
end

RuboCop::CommentConfig.prepend(Rfix::Ext::CommentConfig)
RuboCop::Cop::Offense.prepend(Rfix::Ext::Offense)

CLI::UI::StdoutRouter.enable

# TODO: Handle cases where color can't be resolved by CLI::UI
RuboCop::Formatter::SimpleTextFormatter::COLOR_FOR_SEVERITY.each do |severity, color|
  id = RuboCop::Cop::Severity::CODE_TABLE.invert.fetch(severity)
  CLI::UI::Glyph.new(id.to_s, 0x25cf, CLI::UI.resolve_color(color))
end

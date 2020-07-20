# frozen_string_literal: true

require "rubocop"
require "rfix/log"

module Rfix
  include Log
  attr_accessor :repo
  attr_accessor :test

  alias test? test

  def global_enable!
    @global_enable = true
  end

  def global_enable?
    @global_enable
  end

  def refresh!(source)
    return true if global_enable?

    repo.refresh!(source.file_path)
  end

  def enabled?(path, line)
    return true if global_enable?

    repo.include?(path, line)
  end
end

# rubocop:enable Layout/LineLength

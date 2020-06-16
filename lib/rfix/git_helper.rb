# frozen_string_literal: true

require "open3"
require "rfix"
require "rfix/log"
require "rfix/cmd"

module Rfix::GitHelper
  include Rfix::Log
  include Rfix::Cmd

  def git(*args)
    cmd("git", *args)
  end

  def params
    [
      "--word-diff-regex=[^[:space:]]",
      "--no-renames",
      "--no-merges",
      "--first-parent",
      "--diff-filter=AM",
      "-U0",
      "--no-color",
      "-p"
    ]
  end
end

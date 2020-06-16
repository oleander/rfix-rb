# frozen_string_literal: true

require "open3"
require "rfix"
require "rfix/log"

module Rfix::Cmd
  include Rfix::Log

  def cmd(*args)
    out, err, status = Open3.capture3(*args)

    unless status.success?
      return yield if block_given?

      say_error "[Cmd] " + args.join(" ")
      say_error "[Path] " + Dir.pwd
      say_error "[Stderr] " + err.strip
      say_error "[Stdout] " + out.strip
      exit status.exitstatus
    end

    out.lines.map(&:chomp)
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

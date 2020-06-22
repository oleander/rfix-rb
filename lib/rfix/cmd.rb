# frozen_string_literal: true

require "open3"
require "rfix"
require "rfix/log"

module Rfix::Cmd
  include Rfix::Log

  def cmd(*args, quiet: false)
    out, err, status = Open3.capture3(*args)
    box = Rfix::Box.new(out, err, status, args, quiet)

    box.render(debug: true)

    return box.stdout if box.success?

    return yield if block_given?

    return if quiet

    box.render(color: :red)

    exit box.exit_status
  end

  def cmd_succeeded?(*cmd)
    Open3.capture2e(*cmd).last.success?
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

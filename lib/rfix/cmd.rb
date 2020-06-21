# frozen_string_literal: true

require "open3"
require "rfix"
require "rfix/log"

module Rfix::Cmd
  include Rfix::Log

  def cmd(*args, quiet: false)
    out, err, status = Open3.capture3(*args)

    # say "[Cmd] {{italic:#{args.join(' ')}}}"
    unless status.success?
      return yield if block_given?
      return if quiet

      say_error "[Cmd] {{italic:#{args.join(' ')}}}"
      say_error "[Pwd] {{italic:#{Dir.pwd}}}"
      say_error "[Err] {{error:#{err.strip}}}"

      exit status.exitstatus
    end

    out.lines.map(&:chomp)
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

# frozen_string_literal: true

require "open3"
require "rfix"
require "rfix/log"
require "rfix/cmd"

module Rfix::GitHelper
  include Rfix::Log
  include Rfix::Cmd

  def git(*args, root: Dir.pwd, quiet: false, &block)
    args.unshift *["--git-dir", File.join(root, ".git")]
    args.unshift *["--work-tree", root]
    cmd("git", *args, quiet: quiet, &block)
  end

  def has_branch?(branch)
    cmd_succeeded?("git", "cat-file", "-t", branch)
  end

  def params
    [
      "--word-diff-regex=[^[:space:]]",
      "--no-renames",
      "--no-merges",
      "--first-parent",
      "--find-renames",
      "--find-copies",
      "--diff-filter=AMCR",
      "-U0",
      "--no-color",
      "-p"
    ]
  end
end

# TODO: Rename above to just ::Git
module Rfix::Git
  extend Rfix::GitHelper
end

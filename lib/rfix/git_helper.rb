# frozen_string_literal: true

require "open3"
require "rfix"
require "rfix/log"
require "rfix/cmd"
require "shellwords"

module Rfix
  module GitHelper
    include Log
    include Cmd

    def git(*params, root: Dir.pwd, quiet: false, &block)
      args = split_args(params)
      args.unshift("--git-dir", File.join(root, ".git"))
      args.unshift("--work-tree", root)
      cmd("git", *args, quiet: quiet, &block)
    end

    def split_args(params)
      return if params.empty?
      return split(params.first) if params.count == 1

      return params
    end

    def split(str)
      Shellwords.split(str)
    end

    def dirty?(path)
      Dir.chdir(path) do
        !cmd_succeeded?("git diff --quiet")
      end
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
end

# TODO: Rename above to just ::Git
module Rfix
  module Git
    extend GitHelper
  end
end

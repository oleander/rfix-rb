# frozen_string_literal: true

require "rubocop"
require "optparse"
require "rbconfig"
require "rfix/git_file"
require "rfix/git_helper"
require "rfix/log"
require "rfix/tracked_file"
require "rfix/untracked_file"

module Rfix
  include GitHelper
  include Log

  def git_version
    cmd("git --version").last.split(/\s+/, 3).last
  end

  def ruby_version
    RbConfig::CONFIG["ruby_version"] || "<unknown>"
  end

  def current_os
    RbConfig::CONFIG["host_os"] || "<unknown>"
  end

  def global_enable!
    @global_enable = true
  end

  def global_enable?
    @global_enable
  end

  def init!
    @files ||= {}
    @global_enable = false
  end

  def files
    @files.values
  end

  def spin
    @spin ||= CLI::UI::SpinGroup.new
  end

  def paths
    @files.keys
  end

  def root_dir
    @root_dir ||= git("rev-parse", "--show-toplevel").first
  end

  def refresh!(source)
    @files[source.file_path]&.refresh!
  end

  def enabled?(path, line)
    return true if global_enable?

    @files[path]&.include?(line)
  end

  def to_relative(path:)
    Pathname.new(path).relative_path_from(Pathname.new(root_dir)).to_s
  rescue ArgumentError
    path
  end

  def load_untracked!
    cached(list_untrack_files.map do |path|
      UntrackedFile.new(path, nil, root_dir)
    end.select(&:file?).to_set)
  end

  def load_tracked!(reference)
    cached(git("log", "--name-only", "--pretty=format:", *params, "#{reference}..HEAD").map do |path|
      TrackedFile.new(path, reference, root_dir)
    end.select(&:file?).to_set)
  end

  def has_branch?(name)
    Open3.capture2e("git", "cat-file", "-t", name).last.success?
  end

  # Ref since last push
  def ref_since_push
    git("rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}") do
      [ref_since_origin]
    end.first
  end

  # Original branch, usually master
  def ref_since_origin
    git("show-branch", "--merge-base").first
  end

  private

  def get_file(path, &block)
    if file = @files[path]
      block.call(file)
    end
  end

  def list_untrack_files
    git("status", "-u", "--porcelain", "--no-column").map do |line|
      line.split(" ", 2).map(&:strip)
    end.select { |el| el.first == "??" }.map(&:last)
  end

  def cached(files)
    @files ||= {}
    files.each do |file|
      @files[file.path] = file
    end
  end
end

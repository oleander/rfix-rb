# frozen_string_literal: true

require "dry/struct"
require "rugged"
require "pry"

module Rfix
  class Diff < Dry::Struct
    # https://github.com/libgit2/rugged/blob/master/ext/rugged/rugged_diff.c

    attribute :options, Types::Hash.default(EMPTY_HASH)
    attribute :repository, Repository

    delegate :index, :origin, to: :repository
    delegate :each_line, to: :diff

    alias lines each_line

    OPTIONS = {
      context_lines: 1,
      ignore_whitespace: true,
      ignore_whitespace_change: true,
      ignore_whitespace_eol: true,
      disable_pathspec_match: true,
      ignore_submodules: true,
      include_ignored: false,
      include_unmodified: false,
      skip_binary_check: true,
      ignore_filemode: true,
      include_untracked_content: false,
      include_typechange: false
    }.freeze

    def deltas
      diff.deltas.reject(&:deleted?)
    end

    private

    def diff
      origin.diff(index, **extended_options).tap do |diff|
        diff.merge!(index.diff(**extended_options))
        diff.find_similar!(all: true, ignore_whitespace: true)
      end
    end

    def extended_options
      OPTIONS.merge(**options)
    end
  end
end

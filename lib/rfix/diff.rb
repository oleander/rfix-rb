require "dry/struct"
require "rugged"

module Rfix
  class Diff < Dry::Struct
    attribute :options, Types::Hash.default(EMPTY_HASH)
    attribute :repository, Repository

    delegate :index, :origin, to: :repository
    delegate :deltas, :each_line, to: :diff

    alias_method :lines, :each_line

    OPTIONS = {
      context_lines: 1,
      ignore_whitespace: true,
      ignore_whitespace_change: true,
      ignore_whitespace_eol: true,
      disable_pathspec_match: true,
      ignore_submodules: true,
      include_ignored: false,
      include_unmodified: false,
      include_untracked_content: false,
      include_typechange: false
    }.freeze

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

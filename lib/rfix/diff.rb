# frozen_string_literal: true

require "dry/struct"
require "rugged"

module Rfix
  class Diff < Dry::Struct
    # https://github.com/libgit2/rugged/blob/master/ext/rugged/rugged_diff.c

    attribute :options, Types::Hash.default(EMPTY_HASH)
    attribute :current_path, Types::Path::Relative.default(Pathname(".").freeze)
    attribute :repository, Repository

    delegate :index, :origin, to: :repository
    delegate :each_line, to: :diff

    alias lines each_line

    OPTIONS = {
      context_lines: 1,
      ignore_whitespace: true,
      ignore_whitespace_change: true,
      ignore_whitespace_eol: true,
      disable_pathspec_match: false,
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

    def files
      deltas.map(&:new_file).map do |file|
        repository.path.join(file.fetch(:path))
      end
    end

    private

    def diff
      origin.diff(index, **extended_options).tap do |diff|
        diff.merge!(index.diff(**extended_options))
        diff.find_similar!(all: true, ignore_whitespace: true)
      end
    end

    def absolute_path
      repository.path.join(current_path)
    end

    def extended_options
      unless absolute_path.exist?
        raise Error, "#{current_path} path does not exist in #{repository.path}"
      end

      unless absolute_path.directory?
        raise Error, "#{current_path} is not a directory"
      end

      OPTIONS.merge(**options, paths: [current_path.join("**/*").to_s])
    end
  end
end

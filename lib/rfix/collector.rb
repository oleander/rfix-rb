# frozen_string_literal: true

require "dry/struct"

module Rfix
  class Collector < Dry::Struct
    # https://github.com/libgit2/rugged/blob/master/lib/rugged/tree.rb
    OPTIONS = {
      include_untracked_content: true,
      ignore_whitespace_change: false,
      recurse_untracked_dirs: true,
      ignore_whitespace_eol: false,
      disable_pathspec_match: true,
      include_unmodified: true,
      include_untracked: true,
      ignore_submodules: true,
      include_ignored: false,
      deltas_are_icase: true,
      ignore_filemode: true,
      force_text: true,
      context_lines: 0
    }.freeze

    attribute :repository, Repository
    attribute :reference, Types::String

    delegate_missing_to :repository

    include Enumerable

    def each(&block)
      construct = lambda do |path, statuses|
        File.call(basename: path, status: statuses, repository: repository)
      end

      statuses = Hash.new(EMPTY_ARRAY).tap do |statuses|
        repository.status do |path, status|
          statuses[path] = status
        end
      end

      if repository.head_unborn?
        statuses.each do |path, status|
          (block << construct).call(path, status)
        end
      else
        origin.diff_workdir(**OPTIONS.dup).tap do |diff|
          diff.find_similar!(
            renames_from_rewrites: true,
            renames: true,
            copies: true
          )
        end.each_delta do |delta|
          delta.new_file.fetch(:path).then do |file_path|
            (block << construct).call(file_path, statuses[file_path] + [delta.status])
          end
        end
      end
    end

    private

    def origin
      repository.lookup(repository.rev_parse(reference).oid)
    rescue Rugged::Error, Rugged::InvalidError, Rugged::ReferenceError
      raise Error, "Reference #{reference.inspect} not found"
    end
  end
end

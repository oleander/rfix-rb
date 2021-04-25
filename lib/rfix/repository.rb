# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "dry/core/constants"
require "dry/core/memoizable"
require "dry/struct"
require "rugged"

module Rfix
  class Repository < Dry::Struct
    include Log

    module Types
      include Dry::Types()
    end

    include Dry::Core::Constants
    include Dry::Core::Memoizable

    attribute :repository, Types.Instance(Rugged::Repository)
    attribute :reference, Types.Instance(Branch::Base)

    delegate :head, :branches, :workdir, :rev_parse, to: :repository

    OPTIONS = {
      include_untracked_content: true,
      ignore_whitespace_change: false,
      recurse_untracked_dirs: true,
      ignore_whitespace_eol: false,
      include_unmodified: false,
      include_unmodified: true,
      include_untracked: true,
      ignore_submodules: true,
      include_ignored: false,
      context_lines: 0
    }.freeze

    def self.new(**)
      super.tap(&:call)
    end

    def status(found = EMPTY_HASH.dup)
      @status ||= begin
        repository.status do |path, statuses|
          statuses.each do |status|
            (found[path] ||= []) << status
          end
        end

        if repository.head_unborn?
          return found
        end

        repository.head.target.diff(**OPTIONS.dup).tap do |diff|
          diff.find_similar!(
            renames_from_rewrites: true,
            renames: true,
            copies: true
          )
        end.each_delta.each_with_object(found) do |delta, acc|
          (acc[delta.new_file[:path]] ||= []) << delta.status
        end
      end
    end

    def call
      @call ||= begin
        status.each do |path, statuses|
          build(path, statuses)
        end
      end
    end

    # @path [String]
    def refresh!(path)
      get(path).refresh!
    end

    # @path [String]
    # @line [Integer]
    # @return Bool
    def include?(path, line)
      get(path).include?(line: line)
    end

    # @return [Branch]
    def current_branch
      Branch::Name.new(branches[head.name].name)
    end

    # @return [Array]
    def local_branches
      branches.each_name(:local).to_a
    end

    def skipped
      ignored + deleted
    end

    def tracked
      files.values.select(&:tracked?)
    end

    def ignored
      files.values.select(&:ignored?)
    end

    def untracked
      files.values.select(&:untracked?)
    end

    def deleted
      files.values.select(&:deleted?)
    end

    def permitted
      untracked + tracked
    end

    def to_s
      options = {
        untracked: untracked.map(&:basename).join(", "),
        tracked: tracked.map(&:basename).join(", "),
        ignored: ignored.map(&:basename).join(", "),
        deleted: deleted.map(&:basename).join(", ")
      }

      "Repository<Untracked: %<untracked>s, Tracked: %<tracked>s, Ignored: %<ignored>s, Deleted: %<deleted>s>" % options
    end

    def files
      @files ||= EMPTY_HASH.dup
    end

    def paths
      permitted.map(&:basename)
    end

    private

    # @return [Rugged::Commit]
    def upstream
      @upstream ||= reference.resolve(with: repository)
    end

    def store(file)
      files.store(file.key, file)
    end

    def get(path)
      permitted.map do |file|
        [file.key, file]
      end.to_h.fetch(path)
    end

    def build(path, status)
      store(Rfix::File.call(basename: path, status: status, repository: repository))
    rescue Dry::Struct::Error => e
      raise Error, {path: path, status: status, message: e.message}.inspect
    end
  end
end

# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/inclusion"
require "dry/core/memoizable"
require "dry/core/constants"
require "concurrent/map"
require "dry/struct"
require "rugged"

module Rfix
  class Repository < Dry::Struct
    include Dry::Core::Constants
    include Dry::Core::Memoizable

    attribute :repository, Types.Instance(Rugged::Repository)
    attribute :reference, Types.Instance(Branch::Base)

    INCLUDED = [File::Untracked, File::Tracked].to_set.freeze
    INIT = Hash.new { |h, k| h[k] = EMPTY_ARRAY.dup }

    delegate_missing_to :repository

    def self.method_added(name)
      super.tap { memoize(name) }
    end

    def include?(path, line)
      !!cache[path]&.include?(line)
    end

    def contains?(path)
      cache.key?(path)
    end

    def skipped
      ignored + deleted
    end

    def tracked
      files.select(&:tracked?)
    end

    def ignored
      files.select(&:ignored?)
    end

    def untracked
      files.select(&:untracked?)
    end

    def deleted
      files.select(&:deleted?)
    end

    def path
      Pathname(workdir)
    end

    def cache
      Concurrent::Map.new.tap do |map|
        files.each { |file| map[file.key] ||= file }
      end
    end

    def files
      options = {
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
      }

      diff = origin.diff(repository.index, **options)
      diff.merge!(repository.index.diff(**options))
      diff.find_similar!(all: true, ignore_whitespace: true)

      diff.deltas.map do |delta|
        File::Tracked.call(
          repository: self,
          status: [:tracked],
          basename: delta.new_file.fetch(:path)
        )
      end
    end

    def permitted
      files.select do |file|
        file.class.in?(INCLUDED)
      end
    end

    def to_s
      files.each_with_object(INIT) do |file, object|
        object[file.class] << file
      end.map do |type, files|
        "%<type>s[%<count>i]:%<files>s" % {
          files: files.map(&:to_s).join(", "),
          type: type.name.demodulize,
          count: files.count
        }
      end.then do |types|
        "Repository<%<types>s>" % { types: types.join(", ") }
      end
    end
    alias inspect to_s

    def paths
      permitted.map(&:path).map(&:to_path).to_a
    end

    def include_file?(path)
      Types::Path::Absolute.call(path).then do |absolute_path|
        cache[absolute_path.to_s].class.in?(INCLUDED)
      end
    end

    # TODO: Refactor
    def origin
      repository.lookup(repository.rev_parse(reference.name).oid)
    rescue Rugged::Error, Rugged::InvalidError, Rugged::ReferenceError
      raise Error, "Reference #{reference.name.inspect} not found"
    end

    def collector
      Collector.call(repository: self, reference: reference.name)
    end
  end
end

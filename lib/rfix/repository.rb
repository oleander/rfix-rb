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
    INIT = Hash.new { |h, k| h[k] = EMPTY_ARRAY.dup }.freeze

    delegate_missing_to :repository

    def self.method_added(name)
      super.tap { memoize(name) }
    end

    def include?(path, line)
      cache[path].include?(line)
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
      Concurrent::Map.new do |storage, path|
        storage.fetch(Types::Path::Absolute.call(path).to_s, File::Null)
      end.tap do |storage|
        files.each { |file| storage.compute_if_absent(file.key) { file } }
      end
    end

    def current_path
      Pathname.pwd.relative_path_from(path)
    end

    def files
      Diff.new(repository: self, current_path: current_path).deltas.map do |delta|
        File::Tracked.call(**delta.new_file, repository: self, status: delta.status)
      end
    end

    def permitted
      files
    end

    def to_s
      files.each_with_object(INIT.dup) do |file, object|
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
      permitted.map(&:key).to_a
    end

    def include_file?(path, line = Undefined)
      return cache[path].exists? if line == Undefined

      cache[path].include?(line)
    end

    alias contains? include_file?
    alias include? include_file?

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

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
      Diff.new(repository: self).deltas.map do |delta|
        File::Tracked.call(**delta.new_file, repository: self, status: delta.status)
      end
    end

    def permitted
      files
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
      Types::Path::Relative.call(path) && cache[path.to_s]
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

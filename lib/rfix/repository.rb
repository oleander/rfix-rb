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

    attribute? :paths, Types.Array(Types::String).default(EMPTY_ARRAY)
    attribute :repository, Types.Instance(Rugged::Repository)
    attribute? :load_untracked, Types::Bool.default(false)
    attribute :reference, Types.Instance(Branch::Base)

    delegate :head, :branches, :workdir, :rev_parse, :status, to: :repository

    alias_method :load_untracked?, :load_untracked
    alias_method :load_tracked?, :reference
    alias_method :git_path, :workdir

    def initialize(**)
      @files = EMPTY_HASH.dup
      super
      load!
    end

    def store(file)
      @files.store(file.key, file)
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

    # @return [Rugged::Commit]
    def upstream
      @upstream ||= reference.resolve(with: repository)
    end

    private

    def load_tracked!
      params = {
        # ignore_whitespace_change: true,
        include_untracked_content: true,
        recurse_untracked_dirs: true,
        # ignore_whitespace_eol: true,
        include_unmodified: false,
        include_untracked: true,
        ignore_submodules: true,
        # ignore_whitespace: true,
        include_ignored: false,
        context_lines: 0
      }

      unless paths.empty?
        say_debug("Use @paths #{paths.join(', ')}")
        params[:disable_pathspec_match] = false
        params[:paths] = paths
      end

      say_debug("Run diff on {{info:#{reference}}}")
      upstream.diff(head.target, **params).tap do |diff|
        diff.find_similar!(
          renames_from_rewrites: true,
          renames: true,
          copies: true
        )
      end.each_delta do |delta|
        file = File.call(
          repository: repository,
          status: delta.status,
          path: delta.new_file[:path]
        )

        store(file)
      end
    end

    def load!
      load_tracked!
      load_untracked!
    end

    def load_untracked!
      status do |path, status|
        File.call(path: path, status: status, repository: repository)
      end
    end

    private

    def get(path)
      @files.fetch(path)
    rescue KeyError
      raise Error, "#{path} not found among #{@files.keys}"
    end
  end
end

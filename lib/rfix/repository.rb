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

    OPTIONS = {
      include_untracked_content: true,
      recurse_untracked_dirs: true,
      include_unmodified: false,
      include_untracked: true,
      ignore_submodules: true,
      include_ignored: false,
      context_lines: 0
    }


    def self.call(**)
      super.tap(&:call)
    end

    def call
      # Untracked files
      status do |path, status|
        build(path, status)
      end

      # Tracked files
      unless paths.empty?
        params[:disable_pathspec_match] = false
        params[:paths] = paths
      end

      upstream.diff(head.target, **OPTIONS).tap do |diff|
        diff.find_similar!(
          renames_from_rewrites: true,
          renames: true,
          copies: true
        )
      end.each_delta.map do |delta|
        build(delta.new_file[:path], delta.status)
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

    private

    # @return [Rugged::Commit]
    def upstream
      @upstream ||= reference.resolve(with: repository)
    end

    def files
      @files ||= EMPTY_HASH.dup
    end

    def store(file)
      files.store(file.key, file)
    end

    def get(path)
      files.fetch(path)
    rescue KeyError
      raise Error, "#{path} not found among #{files.keys}"
    end

    def build(path, status)
      store(File.call(basename: path, status: status, repository: repository))
    end
  end
end

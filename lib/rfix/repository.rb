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

    alias_method :load_untracked?, :load_untracked
    alias_method :load_tracked?, :reference

    delegate :head, :branches, :workdir, :rev_parse, :status, to: :repository

    def initialize(**)
      super
      load!
    end

    def files
      @files ||= FileCache.new(repository.path)
    end

    def refresh!(path)
      files.get(path).refresh!
    end

    def include?(path, line)
      say_debug "Checking #{path}:#{line}"

      if file = files.get(path)
        return file.include?(line)
      end

      say_debug "\tSkip file (return false)"
      return false
    end

    def set_root(_path_path)
      using_path(root_path)
    end

    def paths
      files.pluck(&:absolute_path)
    end

    def current_branch
      head.name
    end

    def local_branches
      branches.each_name(:local).to_a
    end

    alias_method :git_path, :workdir

    # TODO: Memo
    def head
      @head ||= rev_parse("HEAD")
    end

    # TODO: Memo
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
      upstream.diff(head, **params).tap do |diff|
        diff.find_similar!(
          renames_from_rewrites: true,
          renames: true,
          copies: true
        )
      end.each_delta do |delta|
        path = delta.new_file.fetch(:path)
        say_debug("Found #{path} while diff")
        try_store(path, [delta.status])
      end
    rescue Rugged::ReferenceError
      abort_box($ERROR_INFO.to_s) do
        prt "Reference {{error:#{reference}}} cannot be found in repository"
      end
    rescue Rugged::ConfigError
      abort_box($ERROR_INFO.to_s) do
        prt "No upstream branch set for {{error:#{current_branch}}}"
      end
    rescue TypeError
      abort_box($ERROR_INFO.to_s) do
        prt "Reference {{error:#{reference}}} is not pointing to a tree or commit"
      end
    end

    def load!
      load_tracked!
      load_untracked!
    end

    # https://github.com/libgit2/rugged/blob/35102c0ca10ab87c4c4ffe2e25221d26993c069c/test/status_test.rb
    # - +:index_new+: the file is new in the index
    # - +:index_modified+: the file has been modified in the index
    # - +:index_deleted+: the file has been deleted from the index
    # - +:worktree_new+: the file is new in the working directory
    # - +:worktree_modified+: the file has been modified in the working directory
    # - +:worktree_deleted+: the file has been deleted from the working directory

    MODIFIED  = [:modified, :worktree_modified, :index_modified].freeze
    IGNORED   = [:ignored].freeze
    STAGED    = [:added, :index_new].freeze
    UNTRACKED = [:worktree_new, :untracked].freeze
    COPIED    = [:copied].freeze
    DELETED   = [:deleted, :worktree_deleted, :index_deleted].freeze
    RENAMED   = [:renamed].freeze

    SKIP = [*DELETED, *RENAMED, *COPIED, *IGNORED].freeze
    ACCEPT = [*MODIFIED].freeze

    def load_untracked!
      status do |path, status|
        try_store(path, status)
      end
    end

    def store(file)
      files.add(file)
    end

    def try_store(path, status)
      if SKIP.any?(&status.method(:include?))
        return say_debug("Ignored {{warning:#{status.join(', ')}}} #{path}")
      end

      if STAGED.any?(&status.method(:include?))
        return store(Untracked.new(path, repo, nil))
      end

      if UNTRACKED.any?(&status.method(:include?))
        unless load_untracked?
          return say_debug("Ignore #{path} as untracked files are ignored: #{status}")
        end

        return store(Untracked.new(path, repo, nil))
      end

      if ACCEPT.any?(&status.method(:include?))
        return store(Tracked.new(path, repo, reference))
      end

      say_debug "Status not found {{error:#{status.join(', ')}}} for {{italic:#{path}}}"
    end
  end
end

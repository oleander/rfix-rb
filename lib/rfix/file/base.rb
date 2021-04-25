require "rugged"
require "pathname"
require "dry/struct"

module Rfix
  module File
    class Base < Dry::Struct
      include Log, Dry::Core::Constants

      # https://github.com/libgit2/rugged/blob/35102c0ca10ab87c4c4ffe2e25221d26993c069c/test/status_test.rb
      # - +:index_new+: the file is new in the index
      # - +:index_modified+: the file has been modified in the index
      # - +:index_deleted+: the file has been deleted from the index
      # - +:worktree_new+: the file is new in the working directory
      # - +:worktree_modified+: the file has been modified in the working directory
      # - +:worktree_deleted+: the file has been deleted from the working directory

      TRACKED   = [:modified, :worktree_modified, :index_modified].freeze
      UNTRACKED = [:added, :index_new, :worktree_new, :untracked].freeze
      DELETED   = [:deleted, :worktree_deleted, :index_deleted].freeze
      IGNORED   = [*DELETED, :renamed, :copied, :ignored].freeze

      schema schema.strict
      abstract_class self

      attribute :repository, Types::Rugged
      attribute :basename, Types::String
      alias_method :key, :basename

      # @return [Pathnane]
      def path
        Pathname(repository.workdir).join(basename)
      end

      def key
        basename
      end

      def include?(**)
        raise NotImplementedError, self.class.name
      end

      def refresh!(*)
        raise NotImplementedError, self.class.name
      end

      def inspect
        "<#{self.class.name}({{info:#{basename}}})>"
      end
    end
  end
end

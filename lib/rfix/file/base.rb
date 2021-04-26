# frozen_string_literal: true

require "rugged"
require "pathname"
require "dry/struct"

module Rfix
  module File
    class Base < Dry::Struct
      include Dry::Core::Constants
      include Log

      # https://github.com/libgit2/rugged/blob/35102c0ca10ab87c4c4ffe2e25221d26993c069c/test/status_test.rb
      # - +:index_new+: the file is new in the index
      # - +:index_modified+: the file has been modified in the index
      # - +:index_deleted+: the file has been deleted from the index
      # - +:worktree_new+: the file is new in the working directory
      # - +:worktree_modified+: the file has been modified in the working directory
      # - +:worktree_deleted+: the file has been deleted from the working directory
      # STATUSES = {
      #   "staged_new_file" => [:index_new],
      #   "staged_new_file_deleted_file" => [:index_new, :worktree_deleted],
      #   "staged_new_file_modified_file" => [:index_new, :worktree_modified],
      #   "file_deleted" => [:worktree_deleted],
      #   "modified_file" => [:worktree_modified],
      #   "new_file" => [:worktree_new],
      #   "ignored_file" => [:ignored],
      #   "subdir/deleted_file" => [:worktree_deleted],
      #   "subdir/modified_file" => [:worktree_modified],
      #   "subdir/new_file" => [:worktree_new],
      #   "\xe8\xbf\x99" => [:worktree_new]
      # }

      schema schema.strict
      abstract_class self

      attribute :repository, Types::Rugged
      attribute :basename, Types::String

      UNTRACKED = [:worktree_new, :index_new]
      DELETED = [:deleted, :worktree_deleted]
      IGNORED = [:ignored].freeze
      TRACKED = [:added].freeze

      def key
        path.to_s
      end

      # @return [Pathnane]
      def path
        Pathname(repository.workdir).join(basename)
      end

      def include?(**)
        raise NotImplementedError, self.class.name
      end

      def refresh!(*)
        # NOP
      end

      def inspect
        "<#{self.class.name}(#{status.join(', ')}:#{basename})>"
      end

      %i[untracked? tracked? ignored? deleted?].each do |name|
        define_method(name) do
          false
        end
      end
    end
  end
end

require "active_support/core_ext/module/delegation"
require "dry/core/constants"

module Rfix
  class FileCache < Dry::Struct
    include Dry::Core::Constants, Log
    NoFileFound = Class.new(Error)

    attribute :repository, Types::Rugged

    using Module.new {
      refine String do
        def key
          Pathname(self).realpath
        end
      end
    }

    def initialize(**)
      @files = EMPTY_HASH.dup
      @paths = EMPTY_HASH.dup

      super
    end

    def add(file_path)
      @files[key(file_path)] = file_path
    end

    def get(file_path)
      @files.fetch(key(file_path)) do
        raise NoFileFound, file_path
      end
    end

    def files
      @files.values
    end

    private

    def path
      Pathname(repository.path)
    end

    def key(file)
      path.join(file).realpath
    end
  end
end

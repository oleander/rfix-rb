require "pathname"

module Rfix
  class GitFile
    include GitHelper
    attr_reader :path, :ref

    def initialize(path, ref, root_dir)
      @path = File.join(root_dir, path)
      @root_dir = Pathname.new(root_dir)
      @ref = ref
      @ranges = []
    end

    def file?
      File.file?(path)
    end

    def ==(other)
      path == other.path
    end

    def eql?(other)
      path == other.path
    end

    def hash
      path.hash
    end

    def relative_path
      Pathname.new(path).relative_path_from(@root_dir).to_s
    end
  end
end

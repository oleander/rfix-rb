module Rfix
  class FileCache
    attr_reader :root_path

    include Log

    def initialize(path)
      @files = Hash.new
      @paths = Hash.new
      @root_path = path
    end

    def add(file)
      key = normalized_file_path(file)

      if @files.key?(key)
        return say_debug("File already exists with path {{error:#{file.path}}} using #{key}")
      end

      say_debug("Adding file with path {{green:#{file.path}}} using key {{info:#{key}}}")
      @files[key] = file
    end

    def get(path)
      key = normalize_path(path)

      if file = @files[key]
        say_debug("Found file #{file} with path #{path}")
        return file
      end

      say_debug("Could {{error:NOT}} find path #{path}")
      nil
    end

    def pluck(&block)
      @files.values.map(&block)
    end

    private

    def normalized_file_path(file)
      normalize_path(file.absolute_path)
    end

    def to_abs(path)
      ::File.join(root_path, path)
    end

    def normalize_path(path)
      if cached = @paths[path]
        return cached
      end

      if Pathname.new(path).absolute?
        @paths[path] = ::File.realdirpath(path)
      else
        @paths[path] = ::File.realdirpath(to_abs(path))
      end
    end
  end
end

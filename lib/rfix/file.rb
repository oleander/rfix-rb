require "pathname"

module Rfix
  class File < Struct.new(:path, :repo, :ref)
    include Log

    def check_absolute!(path)
      if Pathname.new(path).absolute?
        say_abort "Path must be relative #{path}"
      end
    end

    def include?(_)
      raise Error, "#include? not implemented"
    end

    def refresh!
      raise Error, "#refresh! not implemented"
    end

    def inspect
      raise Error, "#inspect not implemented"
    end

    def git_path
      @git_path ||= Pathname.new(repo.workdir)
    end

    def absolute_path
      path
      # @absolute_path ||= to_abs(path)
    end

    def to_abs(path)
      File.join(repo.workdir, path)
    end

    alias to_s path
  end
end

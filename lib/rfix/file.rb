require "rugged"
require "shellwords"
require "digest"
require "listen"

class Rfix::File < Struct.new(:path, :repo, :ref)
  include Rfix::Log

  def initialize(path, repo, ref)
    # check_absolute!(path)
    super(path, repo, ref)
  end

  def check_absolute!(path)
    if Pathname.new(path).absolute?
      say_abort "Path must be relative #{path}"
    end
  end

  def include?(_)
    raise Rfix::Error, "#include? not implemented"
  end

  def refresh!
    raise Rfix::Error, "#refresh! not implemented"
  end

  def inspect
    raise Rfix::Error, "#inspect not implemented"
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

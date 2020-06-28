require "colorize"
require "fileutils"
require "shellwords"

module Support
  include FileUtils
  alias _sh sh
  alias _cd cd
  alias _rm_rf rm_rf
  alias _rm_f rm_f
  alias _mkdir_p mkdir_p
  alias _chdir chdir

  def say(msg)
    warn "#{'==>'.blue} #{to_relative(msg).italic}"
  end

  def sh(*args)
    args = args.map(&:shellsplit).flatten
    colorize args
    _sh(*args)
  end

  def chdir(*args, &block)
    colorize :cd, args
    _chdir(*args, &block)
  end

  def rm_rf(*args)
    colorize :rm, args
    _rm_rf(*args)
  end

  def rm_f(*args)
    colorize :rm, args
    _rm_f(*args)
  end

  def cd(*args, &block)
    colorize :cd, args
    _cd(*args, &block)
  end

  def mkdir_p(*args)
    colorize :mkdir, args
    _mkdir_p(*args)
  end

  def clone_and_run(&block)
    Dir.mktmpdir do |repo|
      sh "git clone", Bundle::Complex::FILE, repo, "--branch", "master"
      Dir.chdir(repo) { block.call(repo) }
    end
  end

  private

  def current_path
    File.join(Dir.getwd, "/")
  end

  def to_relative(path)
    path.to_s.gsub(current_path, "")
  end

  def colorize(*args)
    head, *tail = args.flatten.map(&method(:to_relative))
    say [head.yellow, tail.join(" ").italic].join(" ")
  end
end

extend Support

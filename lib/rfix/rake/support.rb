require "colorize"
require "fileutils"
require "shellwords"

module Rfix
  module Rake
    module Support
      include FileUtils

      def included(base)
        super

        base.alias_method :_sh, :sh
        base.alias _cd cd
        base.alias _rm_rf rm_rf
        base.alias _rm_f rm_f
        base.alias _mkdir_p mkdir_p
        base.alias _chdir chdir
      end

      def gemfiles
        Dir["Gemfile*", "ci/Gemfile*"]
      end

      def say(msg)
        $stderr.puts "#{'==>'.blue} #{to_relative(msg).italic}"
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
  end
end

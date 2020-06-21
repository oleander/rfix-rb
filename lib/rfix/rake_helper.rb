require "tmpdir"

module RakeHelper
  include Rfix::Log
  include Rfix::Cmd
  include Rfix::GitHelper

  def dirty?
    !cmd_succeeded?("git diff --quiet")
  end

  def clone(github:, ref:)
    Dir.mktmpdir(github.split("/")) do |src|
      say "Clone {{info:#{github}}}, hold on ..."
      git("clone", "https://github.com/#{github}", src)
      Dir.chdir(src) do
        say "Check out {{info:#{ref}}}"
        git("reset", "--hard", ref)
        git("clean", "-f", "-d")
      end

      dest = File.join("vendor", github)
      say "Copy files to {{info:#{dest}}}"
      FileUtils.mkdir_p(dest)
      FileUtils.copy_entry(src, dest, true, true, true)
    end
  end

  def gemfiles
    Dir.glob("ci/Gemfile*").unshift("Gemfile").reject do |path|
      [".lock", ".base"].include?(File.extname(path))
    end
  end

  def gemlocks
    Dir.glob("ci/Gemfile*.lock").unshift("Gemfile.lock")
  end

  def source_for(name:)
    bundle_root = Bundler.bundle_path.join('bundler/gems')
    path = Dir.glob(bundle_root.join("#{name}-*").to_s).first
    path or raise "Could not find source for #{name}, run bundle install first"
  end

  def dest_for(name:)
    File.join(__dir__, 'vendor', name)
  end

  def osx?
    ENV.fetch("TRAVIS_OS_NAME") == "osx"
  end

  def brew_url(ref:)
    "https://raw.githubusercontent.com/Homebrew/homebrew-core/#{ref}/Formula/git.rb"
  end
end

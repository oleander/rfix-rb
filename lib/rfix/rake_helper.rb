module RakeHelper
  include Rfix::Log
  include Rfix::Cmd

  def dirty?
    !cmd_succeeded?("git diff --quiet")
  end

  def gemfiles
    Dir.glob("ci/Gemfile*").unshift("Gemfile").reject do |path|
      [".lock", ".base"].include?(File.extname(path))
    end
  end

  def source_for(name:)
    bundle_root = Bundler.bundle_path.join('bundler/gems')
    path = Dir.glob(bundle_root.join("#{name}-*").to_s).first
    path or raise "Could not find source for #{name}, run bundle install first"
  end

  def dest_for(name:)
    File.join(__dir__, 'vendor', name)
  end

  def setup(gem:)
    say "Gem {{info:#{gem}}}"
    Bundler.setup(gem)

    source = source_for(name: gem)
    say "Source {{info:#{source}}}"

    dest = dest_for(name: gem)
    say "Dest {{info:#{dest}}}"

    FileUtils.mkdir_p(dest)
    say "Symlink {{info:#{gem}}}"
    FileUtils.symlink(source, dest, force: true)
  end

  def no_gemspec
    say "Disable gemspec group"
    cmd("bundle config set without 'gemspec'")
    yield
    say "Enable gemspec group"
    cmd("bundle config unset without")
  end

  def deployment
    say "Enable deployment"
    cmd("bundle config set deployment 'true'")
    yield
    say "Disable deployment"
    cmd("bundle config set deployment 'false'")
  end

  def osx?
    ENV.fetch("TRAVIS_OS_NAME") == "osx"
  end

  def brew_url(ref:)
    "https://raw.githubusercontent.com/Homebrew/homebrew-core/#{ref}/Formula/git.rb"
  end
end

require "bundler"

module GemHelper
  def source_for(name:)
    bundle_root = Bundler.bundle_path.join('bundler/gems')
    path = Dir.glob(bundle_root.join("#{name}-*").to_s).first
    path or raise "Could not find source for #{name}, run bundle install first"
  end
end

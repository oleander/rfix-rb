class Bundler
  def self.use_system_gems?
    false
  end

  def self.locked_version
    nil
  end

  def locked_version?
    false
  end

  def self.gemfile_path
    nil
  end
end

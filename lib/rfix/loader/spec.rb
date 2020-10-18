class Gem::Specification
  def self.deactivate(name)
    Gem.loaded_specs[name]&.deactivate
  end

  def deactivate
    loaded_paths.each do |path|
      $:.delete(path)
    end

    Gem.loaded_specs.delete(name)
  end

  def activation
    self.class.deactivate(name)
    activate
  rescue Gem::ConflictError => error
    abort error.to_s
  end

  private

  def loaded_paths(spec = self, prev = [])
    return root_loaded_path unless loaded_into_path?
    return root_loaded_path if prev == root_loaded_path

    root_loaded_path + dependent_specs.map do |spec|
      loaded_paths(spec, root_loaded_path)
    end.flatten
  end

  def loaded_into_path?
    @lip ||= root_loaded_path.any? do |path|
      $:.include?(path)
    end
  end

  def root_loaded_path
    @root ||= Dir.glob(lib_dirs_glob)
  end
end

class FileCache
  attr_reader :root_path
  include Rfix::Log

  def initialize(path)
    @files = Hash.new
    @paths = Hash.new
    @root_path = path
  end

  def add(file)
    @files[normalized_file_path(file)] ||= file
  end

  def get(path)
    @files[normalize_path(path)]
  end

  def pluck(&block)
    @files.values.map(&block)
  end

  private

  def normalized_file_path(file)
    normalize_path(file.absolute_path)
  end

  def to_abs(path)
    File.join(root_path, path)
  end

  def normalize_path(path)
    if cached = @paths[path]
      return cached
    end

    if Pathname.new(path).absolute?
      @paths[path] = File.realdirpath(path)
    else
      @paths[path] = File.realdirpath(to_abs(path))
    end
  end
end

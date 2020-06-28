class NoFile < Struct.new(:path)
  def include?(line)
    return true
  end

  def divide
    Set.new
  end

  def empty?
    false
  end
end

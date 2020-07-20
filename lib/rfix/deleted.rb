class Rfix::Deleted < Rfix::File
  def include?(_)
    return false
  end

  def refresh!
    # NOP
  end

  def inspect
    "<Deleted({{info:#{path}}})>"
  end
end

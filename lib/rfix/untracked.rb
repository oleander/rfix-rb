class Rfix::Untracked < Rfix::File
  def include?(_)
    return true
  end

  def refresh!
    # NOP
  end

  def inspect
    "<Untracked({{info:#{path}}})>"
  end
end

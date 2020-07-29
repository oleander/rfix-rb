class Rfix::Branch::Base
  def resolve(with:)
    raise Rfix::NotYetImplementedError.new("#resolved")
  end

  def to_s
    raise Rfix::NotYetImplementedError.new("#to_s")
  end

  def revparse(using:, ref:)
    using.rev_parse(ref)
  rescue Rugged::InvalidError
    raise Rfix::Branch::UnknownBranchError.new("Could not find reference {{error:#{ref}}}")
  end
end

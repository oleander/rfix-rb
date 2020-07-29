class Rfix::Branch::Base
  def resolve(with:)
    raise Rfix::NotYetImplementedError, "#resolved"
  end

  def to_s
    raise Rfix::NotYetImplementedError, "#to_s"
  end

  def revparse(using:, ref:)
    using.rev_parse(ref)
  rescue Rugged::InvalidError
    raise Rfix::Branch::UnknownBranchError, "Could not find reference {{error:#{ref}}}"
  end
end

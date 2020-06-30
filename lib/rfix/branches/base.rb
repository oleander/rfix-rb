class Rfix::Branch::Base
  def resolve(with:)
    raise Rfix::NotYetImplementedError.new("#resolved")
  end

  def to_s
    raise Rfix::NotYetImplementedError.new("#to_s")
  end

  def branch(using:)
    names(using: using).last or raise Rfix::Error.new("No named branch found for {{error:#{self}}}")
  end

  def names(using:)
    oid = resolve(with: using).oid
    locals = using.branches.each_name(:local).to_a

    using.branches.select do |branch|
      next false unless locals.include?(branch.name)
      branch.target_id == oid
    end
  end

  def revparse(using:, ref:)
    using.rev_parse(ref)
  rescue Rugged::InvalidError
    raise Rfix::Branch::UnknownBranchError.new("Could not find reference {{error:#{ref}}}")
  end
end

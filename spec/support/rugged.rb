class Rugged::Repository
  def checkout(branch)
    unless ref = branches[branch]
      return create_branch(branch, head.target_id)
    end

    checkout_tree(rev_parse(ref.name))
  end
end

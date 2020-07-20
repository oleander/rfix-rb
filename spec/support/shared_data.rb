module SharedData
  def init_rfix!(root)
    # Rfix.set_root(root)
    # Rfix.init!
    # Rfix.set_main_branch("master")
  end

  def dump!
    status.dump!
  end

  def head
    git.object("HEAD").sha
  end

  def current_branch
    git.branch.name
  end

  def switch(branch)
    git.branch(branch).create
    git.checkout(branch)
    yield(branch)
  end
end

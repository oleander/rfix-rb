# frozen_string_literal: true

require "rfix/git_file"

class Rfix::UntrackedFile < Rfix::GitFile
  def refresh!
    # nothing
  end

  def include?(_line)
    true
  end
end

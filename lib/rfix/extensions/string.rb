require "rfix/log"

# TODO: Use refinements instead
class String
  def fmt
    Rfix::Log.fmt self
  end
end

require "rfix/log"

class String
  def fmt
    Rfix::Log.fmt self
  end
end

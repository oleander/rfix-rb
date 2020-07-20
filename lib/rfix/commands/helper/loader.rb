module Rfix::Loader
  def helper(file, bind)
    path = File.join(__dir__, file + ".rb")
    eval(IO.read(path), bind, path)
  end
end

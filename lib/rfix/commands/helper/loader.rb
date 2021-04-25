# frozen_string_literal: true

module Rfix
  module Loader
    def helper(file, bind)
      path = ::File.join(__dir__, "#{file}.rb")
      eval(IO.read(path), bind, path)
    end
  end
end

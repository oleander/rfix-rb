module Rfix
  module CLI
    module Command
      class Branch < Base
        def call(branch:, **params)
          define(Rfix::Branch::Reference.new(branch), **params)
        end
      end
    end
  end
end

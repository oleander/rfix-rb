module Rfix
  module CLI
    module Command
      class Origin < Base
        def call(**params)
          define(Rfix::Branch::MAIN, **params)
        end
      end
    end
  end
end

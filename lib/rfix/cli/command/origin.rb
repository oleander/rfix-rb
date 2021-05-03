module Rfix
  module CLI
    module Command
      class Origin < Base
        def call(**params)
          define(Rfix::Branch::Main.call, **params)
        end
      end
    end
  end
end

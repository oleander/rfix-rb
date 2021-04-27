module Rfix
  module CLI
    module Command
      class Origin < Base
        def call(**params)
          define(Rfix::Branch::Main.new, **params)
        end
      end
    end
  end
end

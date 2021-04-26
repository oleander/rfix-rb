module Rfix
  module CLI
    module Command
      class Local < Base
        def call(**params)
          define(Rfix::Branch::UPSTREAM, **params)
        end
      end
    end
  end
end

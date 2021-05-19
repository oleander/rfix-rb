# frozen_string_literal: true

module Rfix
  module CLI
    module Command
      class Local < Base
        def call(**params)
          define(Rfix::Branch::Upstream.new, **params)
        end
      end
    end
  end
end

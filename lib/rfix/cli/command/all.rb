# frozen_string_literal: true

module Rfix
  module CLI
    module Command
      class All < Base
        def call(**params)
          walker = Rugged::Walker.new(Rugged::Repository.discover)
          walker.sorting(Rugged::SORT_TOPO | Rugged::SORT_REVERSE)
          walker.push("HEAD")

          unless oid = walker.each_oid(limit: 1).first
            raise Error, "Repository contains no commits"
          end

          define(Rfix::Branch::Reference.new(name: oid), **params)
        end
      end
    end
  end
end

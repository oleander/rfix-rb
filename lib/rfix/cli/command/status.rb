# frozen_string_literal: true

require "active_support/all"
require "tty/tree"
require "pry"

module Rfix
  module CLI
    module Command
      class Status < Base
        def call(**_params)
          walker = Rugged::Walker.new(Rugged::Repository.discover)
          walker.sorting(Rugged::SORT_TOPO | Rugged::SORT_REVERSE)
          walker.push("HEAD")

          unless oid = walker.each_oid(limit: 1).first
            raise Error, "Repository contains no commits"
          end

          ref = Rfix::Branch::Reference.new(name: oid)
          repo = Repository.new(repository: Rugged::Repository.discover, reference: ref)
          files = repo.permitted

          pp files.map(&:status).uniq

          result = files.map do |file|
            file.to_s.split("/").reverse.reduce({}) do |acc, part|
              next { "#{part} (#{file.class}:#{file.status.join(', ')})" => {} } if acc.empty?

              { part.to_s => acc }
            end
          end.reduce(EMPTY_HASH, :deep_merge)

          puts TTY::Tree.new({ root: result }).render
        end
      end
    end
  end
end

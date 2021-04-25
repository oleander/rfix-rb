# frozen_string_literal: true

module Rfix
  module Branch
    class Main < Base
      KEY = "rfix.main.branch"

      def resolve(with:)
        unless name = with.config[KEY]
          # TODO: Do not do this
          with.config[KEY] = "master"
          return resolve(with: with)
        end

        Branch::Name.new(name).resolve(with: with)
      end

      def self.set(branch, at: Dir.pwd)
        Branch.repo(at: at).config[KEY] = branch
      end

      def self.get(at: Dir.pwd)
        Branch.repo(at: at).config[KEY]
      end

      def to_s
        "configured main branch"
      end
    end
  end
end

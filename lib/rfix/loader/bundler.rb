begin
  require "bundler"

  module Bundler
    class Null
      def __materialize__
      end

      def version
        raise "#version not impl."
      end

      alias activation version
      alias __materialize__ version
    end

    def self.locked_specs
      locked_gems&.specs || []
    rescue Bundler::GemfileNotFound
      []
    end

    def self.find_locked(name)
      locked_specs.select do |spec|
        spec.name.casecmp(name).zero?
      end.first
    end

    def self.activate_locked(name)
      find_locked(name).__materialize__.tap(&:activation)
    end
  end
rescue LoadError
  require_relative "null_bundler"
end

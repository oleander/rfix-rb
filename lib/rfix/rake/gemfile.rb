require "dry/types"
require "dry/struct"
require "dry/logic"

module Rfix
  module Rake
    Dry::Types.define_builder(:not) do |type|
      Dry::Types::Constrained.new(type.lax, rule: Dry::Logic::Operations::Negation.new(type.rule))
    end

    class Gemfile < Dry::Struct
      include Dry::Core::Constants, FileUtils

      module Types
        include Dry::Types()

        module Version
          AST = Types::String.enum("0.84")
        end
      end

      attribute :root_path, Types::Instance(Pathname)
      attribute :version, Types::Version::AST.not

      class AST < self
        attribute :version, Types::Version::AST

        def content
          [super, 'gem "rubocop-ast", "< 0.7"', '\n'].join
        end
      end

      FORMAT = "Gemfile.rubocop-%s%s"
      VERSIONS = [
        '0.82',
        '0.83',
        '0.84',
        '0.92',
        '0.93',
        '1.0.0',
        '1.7.0',
        '1.5.0',
        '1.5.1',
        '1.5.2',
        '1.6.1',
        '1.8.1',
        '1.8.0',
        '1.9.0',
        '1.10.0',
        '1.11.0',
        '1.12.0',
        '1.12.1',
        '1.13.0'
      ]

      def self.call(*args, **kwargs, &block)
        (self | AST).call(*args, **kwargs, &block)
      end

      def self.files(root_path)
        VERSIONS.map do |version|
          Gemfile.call(root_path: root_path, version: version)
        end
      end

      def call
        puts "Working with #{version}"

        gemfile.write(content)

        if lockfile.exist?
          lockfile.delete
        end

        bundle_lock
        puts "Finished with #{version}"
      end

      def bundle_lock
        sh *lock_args
      rescue RuntimeError
        sh *lock_args[0..-2]
      end

      def lock_args
        ["bundle", "lock", "--gemfile", gemfile.to_path, "--local"]
      end

      def to_s
        gemfile.to_s
      end

      private

      def gemfile
        root_path.join(FORMAT % [version, EMPTY_STRING])
      end

      def lockfile
        root_path.join(FORMAT % [version, ".lock"])
      end

      def content
        <<~GEMFILE
          eval_gemfile("../Gemfile")
          gem "rubocop", "#{version}"
        GEMFILE
      end
    end
  end
end

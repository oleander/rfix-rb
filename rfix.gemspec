# frozen_string_literal: true

require "pathname"
require_relative "lib/rfix/version"
# require_relative "lib/rfix/gem_helper"

Gem::Specification.new do |spec|
  # extend GemHelper

  spec.name          = "rfix"

  if ENV["TRAVIS"]
    spec.version = "#{Rfix::VERSION}-#{ENV.fetch('TRAVIS_BUILD_NUMBER')}"
  else
    # rubocop:disable Gemspec/DuplicatedAssignment
    spec.version = Rfix::VERSION
    # rubocop:enable Gemspec/DuplicatedAssignment
  end

  spec.authors       = ["Linus Oleander"]
  spec.email         = ["linus@oleander.nu"]
  spec.summary       = "RuboCop CLI that only lints and auto-fixes code you committed by utilizing `git-log` and `git-diff`"
  # rubocop:enable Layout/LineLength

  spec.description   = <<~TEXT
    RuboCop CLI that only lints and auto-fixes code you committed by utilizing `git-log` and `git-diff`. Rfix CLI makes it possible to lint (`rfix lint`) and auto-fix (`rfix local|origin|branch`) code changes since a certain point in history. You can auto-fix code committed since creating the current branch (`rfix origin`) or since pushing to upstream (`rfix local`).

    Includes a RuboCop formatter with syntax highlighting and build in hyperlinks for offense documentation.

    Holds the same CLI arguments as RuboCop. Run `rfix --help` for a complete list or `rfix` for supported commands.
  TEXT
  spec.homepage      = "https://github.com/oleander/rfix-rb"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["homepage_uri"] = spec.homepage
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  validate_file = ->(f) { f.match(%r{^(test|spec|features)/}) }
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject(&validate_file)
  end

  spec.files += Dir.glob("vendor/shopify/cli-ui/lib/**/*").reject(&validate_file)

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "vendor/shopify/cli-ui/lib"]

  spec.requirements << "git, v2.0+"

  spec.add_runtime_dependency "cri", "~> 2.15.10"
  spec.add_runtime_dependency "rainbow", "~> 3.0"
  spec.add_runtime_dependency "rouge", "~> 3.20"
  spec.add_runtime_dependency "rubocop", ">= 0.80"
  spec.add_runtime_dependency "rugged", "~> 1.0.0"
  spec.add_runtime_dependency "git", "~> 1.7.0"
  spec.add_runtime_dependency "listen", "~> 3.0"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "aruba", "~> 1.0"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "pry", "~> 0.13.1"
end

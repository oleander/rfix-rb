# frozen_string_literal: true

require "pathname"
require_relative "lib/rfix/version"

Gem::Specification.new do |spec|
  spec.name          = "rfix"
  spec.version       = Rfix::VERSION
  spec.authors       = ["Linus Oleander"]
  spec.email         = ["linus@oleander.nu"]

  spec.summary       = "Write a short summary, because RubyGems requires one."
  spec.description   = "Write a longer description or delete this line."
  spec.homepage      = "https://github.com/oleander/rfix"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  validate_file = ->(f) { f.match(%r{^(test|spec|features)/}) }
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject(&validate_file)
  end

  spec.files += Dir.glob("vendor/cli-ui/lib/**/*").reject(&validate_file)

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "vendor/cli-ui/lib"]

  spec.add_runtime_dependency "rainbow", "~> 3.0"
  spec.add_runtime_dependency "rouge", "~> 3.20"
  spec.add_runtime_dependency "rubocop", "~> 0.80"

  spec.required_ruby_version = '>= 2.5.0'
end

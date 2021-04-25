# frozen_string_literal: true

require_relative "lib/rfix/version"

Gem::Specification.new do |spec|
  spec.name          = "rfix"
  spec.version       = Rfix::VERSION
  spec.authors       = ["Linus Oleander"]
  spec.email         = ["linus@oleander.nu"]
  spec.summary       = "RuboCop CLI that only lints and auto-fixes code you committed by utilizing `git-log` and `git-diff`"
  spec.description = <<~TEXT
    RuboCop CLI that only lints and auto-fixes code you committed by utilizing `git-log` and `git-diff`. Rfix CLI makes it possible to lint (`rfix lint`) and auto-fix (`rfix local|origin|branch`) code changes since a certain point in history. You can auto-fix code committed since creating the current branch (`rfix origin`) or since pushing to upstream (`rfix local`).

    Includes a RuboCop formatter with syntax highlighting and build in hyperlinks for offense documentation.

    Holds the same CLI arguments as RuboCop. Run `rfix --help` for a complete list or `rfix` for supported commands.
  TEXT

  spec.homepage              = "https://github.com/oleander/rfix-rb"
  spec.license               = "MIT"
  spec.required_ruby_version = ">= 2.5.0"
  spec.files                 = Dir["lib/**/*"]
  spec.executables           = ["rfix"]
  spec.requirements << "git >= 2"

  spec.metadata["homepage_uri"] = spec.homepage

  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "bundler"
  spec.add_runtime_dependency "cri", "~> 2.15.10"
  spec.add_runtime_dependency "dry-core"
  spec.add_runtime_dependency "dry-initializer"
  spec.add_runtime_dependency "dry-struct"
  spec.add_runtime_dependency "dry-types"
  spec.add_runtime_dependency "rainbow", "~> 3.0"
  spec.add_runtime_dependency "rake"
  spec.add_runtime_dependency "rouge", "~> 3.20"
  spec.add_runtime_dependency "rubocop"
  spec.add_runtime_dependency "rugged"
  spec.add_runtime_dependency "strings-ansi"
  spec.add_runtime_dependency "zeitwerk"
end

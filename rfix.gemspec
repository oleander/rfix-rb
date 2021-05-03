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
  spec.required_ruby_version = ">= 2.6"
  spec.files                 = Dir["lib/**/*", "exe/rfix", "vendor/**/*", "rfix.gemspec"]
  spec.executables           << "rfix"
  spec.bindir = 'exe'
  spec.requirements << "git >= 2"

  spec.metadata["homepage_uri"] = spec.homepage

  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "bundler"
  spec.add_runtime_dependency "dry-cli"
  spec.add_runtime_dependency "dry-core"
  spec.add_runtime_dependency "dry-initializer"
  spec.add_runtime_dependency "dry-struct"
  spec.add_runtime_dependency "dry-types"
  spec.add_runtime_dependency "pastel"
  spec.add_runtime_dependency "rainbow", "~> 3.0"
  spec.add_runtime_dependency "rake"
  spec.add_runtime_dependency "rouge", "~> 3.20"
  spec.add_runtime_dependency "rubocop", ">= 0.82.0", "!= 0.85.0"
  spec.add_runtime_dependency "rugged"
  spec.add_runtime_dependency "rubocop-ast"
  spec.add_runtime_dependency "strings"
  spec.add_runtime_dependency "tty-box"
  spec.add_runtime_dependency "tty-link"
  spec.add_runtime_dependency "tty-prompt"
  spec.add_runtime_dependency "tty-screen"
  spec.add_runtime_dependency "zeitwerk"
end

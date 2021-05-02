# frozen_string_literal: true

source "https://rubygems.org"

gemspec

group :development do
  gem "gem-release", require: false

  gem "aruba"
  gem "colorize"
  gem "faker"
  gem "guard", require: false
  gem "guard-rspec", require: false
  gem "jsonpath"
end

group :development, :test do
  gem "git", require: true
  gem "pry", require: true
  gem "pry-rescue"
  gem "pry-stack_explorer"
  gem "rspec"
  gem "rspec-its"
  gem "rubocop-rake"
  gem "rubocop-rspec"
end

gem "dry-cli", path: "vendor/dry-cli", require: "dry/cli"
gem "strings-ansi", github: "piotrmurach/strings-ansi"

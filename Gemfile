# frozen_string_literal: true

source "https://rubygems.org"

group :development do
  gem "gem-release", require: false

  gem "colorize"
  gem "jsonpath"
  gem "faker"
  gem "aruba"
  gem "guard-rspec", require: false
  gem "guard", require: false
end

gemspec path: __dir__

group :development, :test do
  gem "pry", require: true
  gem "rubocop-rspec"
  gem "rubocop-rake"
  gem "rspec-its"
  gem "pry-stack_explorer"
  gem "pry-rescue"
  gem "rspec"
  gem "git", require: true
end

gem "dry-cli", path: "vendor/dry-cli", require: false

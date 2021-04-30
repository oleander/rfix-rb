# frozen_string_literal: true

source "https://rubygems.org"

group :development do
  gem "gem-release", require: false

  gem "aruba"
  gem "colorize"
  gem "faker"
  gem "guard", require: false
  gem "guard-rspec", require: false
  gem "jsonpath"
end

gemspec path: __dir__

group :development, :test do
  gem "git", require: true
  gem "pry", require: true
  gem "pry-rescue"
  gem "pry-stack_explorer"
  gem "rspec"
  gem "rubocop-rake"
  gem "rubocop-rspec"
  gem "rspec-its"
end

gem "dry-cli", path: "vendor/dry-cli", require: false

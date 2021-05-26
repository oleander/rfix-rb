# frozen_string_literal: true

source "https://rubygems.org"

gemspec

group :development do
  gem "gem-release", require: false

  gem "colorize"
  gem "faker"
  gem "guard", require: false
  gem "guard-rspec", require: false

  gem "jsonpath"
end

group :development, :test do
  gem "pry-rescue"
  gem "pry-stack_explorer"

  gem "listen"
  gem "pry", require: true
  gem "pry-theme"
  gem "rake"
  gem "rubocop-rake"
  gem "rubocop-rspec"
end

group :test do
  gem "aruba"
  gem "factory_bot"
  gem "git", require: true
  gem "rspec"
  gem "rspec-its"
end

path "vendor" do
  gem "strings-ansi", require: true
end

gem "rubocop", "~> 1.5"

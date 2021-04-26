# frozen_string_literal: true

eval_gemfile(File.join(__dir__, "Gemfile.base"))

group :development, :test do
  gem "pry", require: true
  gem "rspec-its"
end

gem "cli-ui", path: "vendor/cli-ui", require: false
gem "dry-cli", path: "vendor/dry-cli", require: false
gem "dry-struct", github: "oleander/dry-struct", require: false, branch: "github/feature/module"
gem "git", require: true

gem "rubocop"
gem "rubocop-rspec"

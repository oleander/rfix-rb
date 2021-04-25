eval_gemfile(File.join(__dir__, "Gemfile.base"))

gem "rubocop", "~> 0.85"

group :development, :test do
  gem "pry", require: true
  gem "rspec-its"
end

gem "git", require: true
gem "cli-ui", path: "vendor/cli-ui", require: false
gem "dry-cli", path: "vendor/dry-cli", require: false
gem "dry-struct", github: "oleander/dry-struct", require: false, branch: "github/feature/module"

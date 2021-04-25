# frozen_string_literal: true

module Path
  ROOT = Pathname(__dir__).join("..")

  VENDOR = ROOT.join("vendor")
  DRY = VENDOR.join("dry-cli")
  CLI = VENDOR.join("cli-ui")
end

namespace :vendor do
  directory Path::VENDOR

  desc "Download vendor repositories"
  multitask build: [Path::CLI, Path::DRY]

  desc "Re-download vendors repository"
  task rebuild: %i[flush build]

  desc "Remove vendor repository"
  task :flush do
    rm_rf Path::VENDOR
  end

  file Path::CLI => Path::VENDOR do
    sh "git clone", "https://github.com/shopify/cli-ui", Path::CLI
  end

  file Path::DRY => Path::VENDOR do
    sh "git clone", "https://github.com/dry-rb/dry-cli.git", Path::DRY
  end
end

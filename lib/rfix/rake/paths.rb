module Travis
  SETUP = "travis:setup".freeze
  INSTALL = "travis:install".freeze
  TASKS = "travis:tasks:all".freeze
  GIT = "travis:git:config".freeze
end

module Bundle
  INSTALL = "bundle:install"
  ADD = "bundle:git:add"
  CONFIG = File.join(__dir__, "../../../.rubocop.yml")
  TAG = "rally-point".freeze
  REBUILD = "bundle:rebuild".freeze
  BUILD = "bundle:build".freeze
  ROOT = File.expand_path(File.join(__dir__, "../../.."))
  DIR = File.join(ROOT, "spec/fixtures")
  TMP = File.join(ROOT, "tmp")

  module Simple
    FILE = File.join(DIR, "simple.bundle")
    REPO = File.join(TMP, "simple")
    REBUILD = "bundle:simple:rebuild".freeze
    BUILD = "bundle:simple:build".freeze
    FLUSH = "bundle:simple:flush".freeze
    TEST = "bundle:simple:test".freeze
    TAG = Bundle::TAG
  end

  module Complex
    FILE = File.join(DIR, "complex.bundle")
    REPO = File.join(TMP, "complex")
    GITHUB = "https://github.com/oleander/git-fame-rb".freeze
    REBUILD = "bundle:complex:rebuild".freeze
    BUILD = "bundle:complex:build".freeze
    FLUSH = "bundle:complex:flush".freeze
    TEST = "bundle:complex:test".freeze
    TAG = Bundle::TAG
  end
end

module Vendor
  ROOT = File.expand_path(File.join(__dir__, "../../.."))
  DIR = File.join(ROOT, "vendor/shopify")
  REPO = File.join(DIR, "cli-ui")
  GITHUB = "https://github.com/shopify/cli-ui".freeze
  START = "ef976d".freeze
  BUILD = "vendor:shopify:build".freeze
  REBUILD = "vendor:shopify:rebuild".freeze
  TEST = "vendor:shopify:test".freeze
end

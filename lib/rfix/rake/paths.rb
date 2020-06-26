module Travis
  SETUP = "travis:setup"
  INSTALL = "travis:install"
  TASKS = "travis:tasks:all"
  GIT = "travis:git:config"
end

module Bundle
  CONFIG = File.join(__dir__, "../../../.rubocop.yml")
  TAG = "rally-point"
  REBUILD = "bundle:rebuild"
  BUILD = "bundle:build"

  module Simple
    ROOT = File.expand_path(File.join(__dir__, "../../.."))
    DIR = File.join(ROOT, "spec/fixtures")
    FILE = File.join(DIR, "simple.bundle")
    TMP = File.join(ROOT, "tmp")
    REPO = File.join(TMP, "simple")
    REBUILD = "bundle:simple:rebuild"
    BUILD = "bundle:simple:build"
    FLUSH = "bundle:simple:flush"
    TEST = "bundle:simple:test"
    TAG = Bundle::TAG
  end

  module Complex
    ROOT = File.expand_path(File.join(__dir__, "../../.."))
    DIR = File.join(ROOT, "spec/fixtures")
    FILE = File.join(DIR, "complex.bundle")
    TMP = File.join(ROOT, "tmp")
    REPO = File.join(TMP, "complex")
    GITHUB = "https://github.com/oleander/git-fame-rb"
    REBUILD = "bundle:complex:rebuild"
    BUILD = "bundle:complex:build"
    FLUSH = "bundle:complex:flush"
    TEST = "bundle:complex:test"
    TAG = Bundle::TAG
  end
end

module Vendor
  ROOT = File.expand_path(File.join(__dir__, "../../.."))
  DIR = File.join(ROOT, "vendor/shopify")
  REPO = File.join(DIR, "cli-ui")
  GITHUB = "https://github.com/shopify/cli-ui"
  START = "ef976d"
  BUILD = "vendor:shopify:build"
  REBUILD = "vendor:shopify:rebuild"
  TEST = "vendor:shopify:test"
end

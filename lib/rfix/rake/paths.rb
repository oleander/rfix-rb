# frozen_string_literal: true

module Travis
  SETUP = "travis:setup"
  INSTALL = "travis:install"
  TASKS = "travis:tasks:all"
  GIT = "travis:git:config"
end

module Bundle
  INSTALL = "bundle:install"
  ADD = "bundle:git:add"
  TAG = "rally-point"
  REBUILD = "bundle:rebuild"
  BUILD = "bundle:build"
  ROOT = Dir.getwd
  CONFIG = File.join(ROOT, ".rubocop.yml")
  DIR = File.join(ROOT, "spec/fixtures")
  TMP = File.join(ROOT, "tmp")

  module Simple
    FILE = File.join(DIR, "simple.bundle")
    REPO = File.join(TMP, "simple")
    REBUILD = "bundle:simple:rebuild"
    BUILD = "bundle:simple:build"
    FLUSH = "bundle:simple:flush"
    TEST = "bundle:simple:test"
    TAG = Bundle::TAG
  end

  module Complex
    FILE = File.join(DIR, "complex.bundle")
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
  START = "6058c301bb144c2f33f7910734d08b1490ed8112"
  BUILD = "vendor:shopify:build"
  REBUILD = "vendor:shopify:rebuild"
  TEST = "vendor:shopify:test"
end

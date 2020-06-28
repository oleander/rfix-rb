# frozen_string_literal: true

require "rfix"
require "aruba/rspec"
require "rugged"
require "fileutils"

Aruba.configure do |config|
  config.allow_absolute_paths = true
  config.activate_announcer_on_command_failure = [:stdout, :stderr]
  config.command_runtime_environment = {
    "OVERCOMMIT_DISABLE" => "1",
    "GIT_TEMPLATE_DIR" => ""
  }
end

Dir[File.join(__dir__, "support/**/*.rb")].each(&method(:require))

setup = SetupGit.setup!

RSpec.configure do |config|
  config.include Rfix::Log
  config.include SharedData
  config.include Aruba::Api
  config.include Rfix::Support

  config.order = :random
  config.example_status_persistence_file_path = ".rspec_status"
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!

  unless ENV["CI"]
    config.filter_run focus: true
    config.run_all_when_everything_filtered = true
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  if ENV["CI"]
    config.before(:suite) do
      system "git config --global user.email 'this@is-not-my-email.com'"
      system "git config --global user.name 'John Doe'"
    end
  end
end

RSpec.shared_context "setup:cmd", shared_context: :metadata, type: :aruba do
  subject { last_command_started }

  let(:main) { Dir.mktmpdir("aruba", expand_path(".")) }
  let(:repo) { git.dir.path }
  let(:git) { Git.clone(Bundle::Simple::FILE, "repo", path: main) }
  let(:rugged) { Rugged::Repository.new(repo) }

  around(:each) do |example|
    rugged.status do |path, status|
      raise "expected clean directory, #{path} #{status.join(', ')}"
    end

    if ENV["CI"]
      cd(repo) do
        system "git config user.email 'this@is-not-my-email.com'"
        system "git config user.name 'John Doe'"
      end
    end

    cd(repo) do
      example.run
    end
  end

  def setup_all_files
    setup_files(1)
    load_file(:file)
  end

  before(:each, :branch) do |example|
    checkout("master", "stable")
    upstream("master")
    setup_all_files
    branch_cmd(branch: "master", root: repo, dry: false, main_branch: "master", **load_args(example))
  end

  before(:each, :local) do |example|
    checkout("master", "stable")
    upstream("master")
    setup_all_files
    local_cmd(root: repo, dry: false, main_branch: "master", **load_args(example))
  end

  before(:each, :lint) do |example|
    checkout("master", "stable")
    upstream("master")
    setup_all_files
    lint_cmd(root: repo, main_branch: "master", **load_args(example))
  end

  before(:each, :origin) do |example|
    checkout("master", "stable")
    upstream("master")
    setup_all_files
    origin_cmd(root: repo, dry: false, main_branch: "master", **load_args(example))
  end

  prepend_before(:each, :read_only) do
    rugged.status do |path, status|
      raise "expected a clean directory but got {{italic:#{path}}} with status {{red:#{status.join(', ')}}}"
    end
  end

  after(:each, :read_only) do
    expect(git).not_to be_dirty
  end

  def meta_to_args(keys)
    keys.each_with_object({}) do |key, acc|
      acc[key] = true
    end
  end

  def load_args(example)
    meta_to_args(example.metadata.fetch(:args, []))
  end

  def init_file(file)
    public_send(file.to_sym)
  rescue NoMethodError
    nil
  end

  def load_file(file)
    init_file(file).tap do |file_obj|
      file_obj&.write!
    end
  end

  def setup_files(order)
    if load_file("file#{order}")
      setup_files(order + 1)
    end
  end
end

RSpec.shared_context "setup:git", shared_context: :metadata do
  subject(:git) { setup.git }
  let(:git_path) { setup.git_path }
  let(:rp) { Bundle::TAG }
  let(:status) { git.status }

  around(:each, type: :git) do |example|
    setup.clone!

    if [example.metadata[:type]].flatten.include?(:local)
      Rfix.set_root(setup.git_path)
      Rfix.set_main_branch("master")
      Rfix.reset!
    end

    Dir.chdir(setup.git_path) do
      cd(setup.git_path) do
        example.run
      end
    end
  end

  prepend_before(:suite, type: :git) do
    setup.clone!
  end

  append_after(:suite, type: :git) do
    setup.teardown!
  end
end

RSpec.configure do |config|
  config.include_context "setup:git", type: :git
  config.include_context "setup:cmd", type: :aruba
end

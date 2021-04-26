# frozen_string_literal: true

# require "pry-rescue/rspec"
require "aruba/rspec"
require "rspec/its"
require "rfix"
require "git"

Aruba.configure do |config|
  config.allow_absolute_paths = true
  config.activate_announcer_on_command_failure = %i[stdout stderr]
  config.command_runtime_environment = {
    "OVERCOMMIT_DISABLE" => "1",
    "GIT_TEMPLATE_DIR" => ""
  }
end

Dir[File.join(__dir__, "support/**/*.rb")].sort.each(&method(:require))

setup = SetupGit.setup!

def init!(root)
  Rfix.set_root(root)
  Rfix.init!
  Rfix.set_main_branch("master")
end

RSpec.shared_context "setup", shared_context: :metadata do
  subject(:git) { setup.git }

  let(:git_path) { setup.git_path }
  let(:rp) { SetupGit::RP }
  let(:status) { git.status }
end

RSpec.configure do |config|
  config.include Rfix::Log
  config.include SharedData
  config.include Aruba::Api
  config.include Rfix::Support
  config.include Rfix::FileSetup, type: :aruba

  config.add_setting :debug
  config.debug = true

  if ENV.key?("CI")
    config.debug = false
  end

  config.formatter = :documentation

  config.order = :random

  config.example_status_persistence_file_path = ".rspec_status"
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!

  config.around(:each, type: :git) do |example|
    setup.reset!
    init!(setup.git_path)
    Dir.chdir(setup.git_path) do
      cd(setup.git_path) do
        example.run
      end
    end
  end

  config.prepend_before(:suite, type: :git) do
    setup.clone!
  end

  config.append_after(:suite, type: :git) do
    setup.teardown!
  end

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

  config.after(:each, :success, :git) do
    expect(subject).to have_exit_status(0)
  end

  config.after(:each, :failure, :git) do
    expect(subject).to have_exit_status(1)
  end

  config.after(:each, :read_only, :git) do
    repo.status do |path, status|
      raise "expected [after] clean directory, instead got dirty #{path} #{status.join(', ')}".fmt
    end
  end
end

RSpec.shared_context "setup:git", shared_context: :metadata, type: :aruba do
  subject { last_command_started }

  let(:main_path)  { Dir.mktmpdir("setup-plain", expand_path(".")) }
  let(:repo_path)  { File.join(main_path, "repo") }
  let(:config_path) { File.expand_path(File.join(__dir__, "fixtures/rubocop.yml")) }
  let(:git)      { Git.clone(Bundle::Simple::FILE, "repo", path: main_path, branch: "master") }
  let(:repo)     { Rugged::Repository.discover(repo_path) }

  def setup_git!
    git

    if ENV["CI"]
      cd(repo_path) do
        system "git config user.email 'this@is-not-my-email.com'"
        system "git config user.name 'John Doe'"
      end
    end
  end

  def l(type)
    Change.new(self, git, type)
  end

  def f(type)
    l(type)
  end

  before do |_example|
    repo.status do |path, status|
      raise "expected clean directory, instead got dirty #{path} #{status.join(', ')}".fmt
    end

    if repo.head_detached?
      raise "Head is detached!"
    end
  end

  prepend_before(:each, :upstream) do |example|
    upstream = example.metadata.fetch(:upstream)
    say_debug("Set upstream branch to {{warning:#{upstream}}}")
    cmd "git", "branch", "--set-upstream-to", upstream
  end

  prepend_before(:each, :checkout) do |example|
    branch = example.metadata.fetch(:checkout)
    say_debug("Checkout the {{warning:#{branch}}} branch")
    git.branch(branch).checkout
  end

  append_before(:each, :commits, :git) do |example|
    number_of_times = example.metadata.fetch(:commits)
    say_debug "Creating {{info:#{number_of_times}}} commits"
    number_of_times.times do |_n|
      f(:valid).tracked.write!
    end
  end

  around do |example|
    setup_git!

    cd(repo_path) do
      example.run
    end
  end
end

RSpec.shared_context "setup:plain", :git, shared_context: :metadata do
  include Rfix::Log

  def exec!(metadata)
    to_run = [
      "bundle exec rfix", metadata.fetch(:cmd),
      "--root", Shellwords.escape(repo_path),
      "--config", Shellwords.escape(config_path),
      "--format", "json",
      "--cache", "false",
      "--test"
    ].flatten

    if branch = metadata.fetch(:branch, "master")
      to_run += ["--main-branch", branch]
    end

    to_run += metadata.fetch(:args, [])

    cd(repo_path) do
      run_command_and_stop(to_run.join(" "), fail_on_error: false)
    end

    if !metadata.key?(:failure) && subject.failed?
      subject.dump!
    end
  end

  before do |example|
    setup_files!
    exec!(example.metadata)
  end
end

RSpec.shared_context "repo", shared_context: :metadata do
  let(:test_path) { Pathname(__dir__).join("../tmp/complex") }
  let(:dirname) { test_path.expand_path }
  let(:rugged) { Rugged::Repository.new(test_path) }
  let(:branch) { Rfix::Branch::Reference.new("HEAD~50") }
end

RSpec.configure do |config|
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.include_context "setup:plain", :cmd
  config.include_context "setup:git", :git
  config.include_context "repo", :repo
end

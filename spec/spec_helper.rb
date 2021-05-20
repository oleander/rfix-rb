# frozen_string_literal: true

# require "pry-rescue/rspec"

require "rspec/expectations"
require "aruba/rspec"
require "factory_bot"
require "rspec/its"
require "rfix"
require "pry"
require "git"

Aruba.configure do |config|
  config.activate_announcer_on_command_failure = %i[stdout stderr]
  config.allow_absolute_paths = true
end

Dir[File.join(__dir__, "support/**/*.rb")].sort.each(&method(:require))

module Helper
  def root_path
    Pathname(__dir__).parent
  end
end

RSpec.configure do |config|
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.example_status_persistence_file_path = ".rspec_status"
  config.include FactoryBot::Syntax::Methods
  config.disable_monkey_patching!
  config.include Aruba::Api
  config.order = :random
  config.bisect_runner = :shell
  config.include Helper
end

RSpec.configure do |config|
  config.include_context "repository", repository: true
end

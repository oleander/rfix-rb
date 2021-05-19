# frozen_string_literal: true

RSpec::Matchers.define :stage do |file|
  match do |repository|
    repository.staged.any? do |path|
      path.basename == file.name
    end
  end

  failure_message do |repository|
    "expected that #{repository} would include staged file #{file.name}"
  end
end

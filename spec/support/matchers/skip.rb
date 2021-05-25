# frozen_string_literal: true

RSpec::Matchers.define :skip do |file|
  match do |repository|
    !repository.include_file?(file.absolute_path)
  end

  failure_message do |repository|
    "expected that #{repository} would include ignored file #{file.name}"
  end
end

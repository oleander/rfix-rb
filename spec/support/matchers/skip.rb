RSpec::Matchers.define :skip do |file|
  match do |repository|
    repository.skipped.any? do |path|
      path.basename == file.name
    end
  end

  failure_message do |repository|
    "expected that #{repository} would include ignored file #{file.name}"
  end
end

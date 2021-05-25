# frozen_string_literal: true

RSpec::Matchers.define :track do |file|
  match do |repository|
    repository.include_file?(file.name.to_path).tap do |result|
      # binding.pry
    end
  end

  match_when_negated do |repository|
    !repository.include_file?(file.name.to_path)
  end

  failure_message do |repository|
    "expected that #{repository} would include tracked file [#{file.name}]"
  end

  failure_message_when_negated do |repository|
    "expected that #{repository} would include untracked file [#{file.name}]"
  end

  chain :on_line, :line
end

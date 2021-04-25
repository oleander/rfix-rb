# frozen_string_literal: true

RSpec::Matchers.define :have_offenses_for do |file|
  match do |actual|
    actual.have_offenses_for?(file)
  end

  match_when_negated do |actual|
    !actual.have_offenses_for?(file)
  end

  failure_message do |actual|
    actual.dump!
    "expected #{file.to_path} to have offenses"
  end

  failure_message_when_negated do |actual|
    actual.dump!
    "expected #{file.to_path} not have any offenses"
  end
end

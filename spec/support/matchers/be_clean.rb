RSpec::Matchers.define :be_clean do
  match do |actual|
    !actual.status.dirty?
  end

  failure_message do |actual|
    "expected that git repo would be clean but found #{actual.status.number_of_dirty_files} dirty files"
  end

  failure_message_when_negated do |_actual|
    "expected that git repo to be dirty but was clean"
  end
end

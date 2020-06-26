RSpec::Matchers.define :have_fixed do |file|
  match do |actual|
    actual.stdout.match(/#{file}:\d+:\d+/) && actual.stdout.include?("corrected")
  end

  failure_message do |actual|
    ftm "expected to have fixed {{italic:#{file}}} but it wasn't: #{actual.stdout}"
  end

  failure_message_when_negated do |actual|
    ftm "expected not to have fixed {{italic:#{file}}} but it was #{actual.stdout}"
  end
end

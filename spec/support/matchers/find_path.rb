RSpec::Matchers.define :find_path do |file|
  match do |actual|
    @line ||= /\d+/
    expect(actual.stdout).to match(/#{file}:#{@line}:\d+/)
  end

  match_when_negated do |actual|
    @line ||= /\d+/
    expect(actual.stdout).not_to match(/#{file}:#{@line}:\d+/)
  end

  chain :with_line do |line|
    @line = line
  end

  failure_message do |actual|
    ftm "expected to match {{yellow:#{file}}} on line {{yellow:#{@line}}} in #{actual}"
  end
end

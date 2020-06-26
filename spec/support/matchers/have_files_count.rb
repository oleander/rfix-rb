RSpec::Matchers.define :have_files_count do |expected|
  include Rfix::Log

  match do |actual|
    [actual.stderr, actual.stdout].any? { |std| std.include?("#{expected} files") }
  end

  def got(actual)
    "{{italic:#{actual.stdout}}} and {{italic:#{actual.stderr}}}"
  end

  failure_message do |actual|
    ftm "expected to have output {{italic:#{expected}}} but got #{got(actual)}"
  end

  failure_message_when_negated do |actual|
    ftm "expected not to have output {{italic:#{expected}}} but got #{got(actual)}"
  end
end

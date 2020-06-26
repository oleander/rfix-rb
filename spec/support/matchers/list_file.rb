RSpec::Matchers.define :list_file do |file|
  match do |actual|
    [actual.stderr, actual.stdout].any? do |stream|
      stream.include?(file)
    end
  end

  failure_message do |actual|
    ftm "expected to see {{italic:#{file}}} in output but could not find it in \n\n#{actual.stderr}\n\n#{actual.stdout}"
  end

  failure_message_when_negated do
    ftm "expected not to see {{italic:#{file}}} in output but saw it"
  end
end

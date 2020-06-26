RSpec::Matchers.define :find do |*output|
  match do |actual|
    [actual.stderr, actual.stdout].any? do |stream|
      output.all? do |out|
        stream.include?(out)
      end
    end
  end

  def out
    "#{actual.stdout} and #{actual.stderr}"
  end

  def exp(output)
    "{{italic:#{output}}}"
  end

  failure_message do |actual|
    ftm "expected to have output #{exp(output)} but got #{out}"
  end

  failure_message_when_negated do |actual|
    ftm "expected not to have output #{exp(output)} but got #{out}"
  end
end

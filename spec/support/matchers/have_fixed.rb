RSpec::Matchers.define :have_fixed do |file|
  match do |actual|
    unless actual.has_corrected?(file)
      next false
    end

    if file.all_line_changes.empty?
      next true
    end

    actual.offenses(file) do |offense|
      file.all_line_changes.each do |line|
        unless offense.corrected?(on: line)
          next false
        end
      end
    end
  end

  match_when_negated do |actual|
    !actual.has_corrected?(file)
  end

  failure_message do |actual|
    actual.dump!

    unless actual.has_corrected?(file)
      next "expected #{file.to_path} to have been {{error:fixed}} but #{actual.fixed_lines_str}".fmt
    end

    actual.offenses(file) do |offense|
      file.all_line_changes.each do |line|
        unless offense.corrected?(on: line)
          next "expected #{file.to_path} at line #{line} to have been {{error:fixed}} but #{actual.fixed_lines_str}".fmt
        end
      end
    end

    "{{warning:This should not happend!}}".fmt
  end

  failure_message_when_negated do |actual|
    actual.dump!

    "expected #{file.to_path} not have been {{error:fixed}} but was together with #{actual.fixed_lines_str}".fmt
  end
end

[:untracked, :staged, :tracked].each do |type|
  RSpec::Matchers.alias_matcher :"have_fixed_#{type}_file", :have_fixed
end
RSpec::Matchers.alias_matcher :have_fixed_file, :have_fixed

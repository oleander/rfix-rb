RSpec::Matchers.define :have_linted do |file|
  include Rfix::Log

  match do |actual|
    unless actual.has_linted?(file)
      next false
    end

    if file.all_line_changes.empty?
      next true
    end

    actual.offenses(file) do |offense|
      file.all_line_changes.each do |line|
        unless offense.linted?(on: line)
          next false
        end
      end
    end
  end

  match_when_negated do |actual|
    !actual.has_linted?(file)
  end

  failure_message do |actual|
    if actual.has_corrected?(file)
      next "expected #{file} to have be {{warning:linted}} but was {{error:fixed}}".fmt
    end

    unless actual.has_linted?(file)
      next "expected #{file} to have be {{warning:linted}} but we #{actual.linted_lines_str}".fmt
    end

    actual.offenses(file) do |offense|
      file.all_line_changes.each do |line|
        unless offense.corrected?(on: line)
          next "expected #{file} to have be {{warning:linted}} on line #{line} #{actual.linted_lines_str}".fmt
        end
      end
    end
  end

  failure_message_when_negated do |actual|
    "expected #{file} not to have be {{error:linted}} but was together with #{actual.linted_lines_str}".fmt
  end
end

[:untracked, :staged, :tracked].each do |type|
  RSpec::Matchers.alias_matcher :"have_linted_#{type}_file", :have_linted
end
RSpec::Matchers.alias_matcher :have_linted_file, :have_linted

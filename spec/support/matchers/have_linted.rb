RSpec::Matchers.define :have_linted do |file|

  match do |actual|
    expect(actual.stdout).to_not include("corrected")
    expect(file.all_line_changes).not_to be_empty

    file.all_line_changes.each do |line|
      expect(actual).to find_path(file.to_path).with_line(line)
    end
  end

  match_when_negated do |actual|
    expect(file.all_line_changes).to be_empty

    file.all_line_changes.each do |line|
      expect(actual).not_to find_path(file.to_path).with_line(line)
    end
  end

  failure_message do |actual|
    ftm "expected to find {{italic:#{file}}} in stdout '#{actual.stdout.chomp}'"
  end

  failure_message_when_negated do |actual|
    ftm "expected not to find {{italic:#{file}}} in stdout '#{actual.stdout.chomp}'"
  end
end

[:untracked, :staged, :tracked].each do |type|
  RSpec::Matchers.alias_matcher :"have_linted_#{type}_file" , :have_linted
end

RSpec::Matchers.alias_matcher :have_linted_file , :have_linted

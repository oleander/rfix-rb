RSpec::Matchers.define :have_fixed do |file|
  match do |actual|
    expect(actual.stdout).to include("corrected")
    expect(file.all_line_changes).not_to be_empty

    file.all_line_changes.each do |line|
      expect(actual).to find_path(file.to_path).with_line(line)
    end
  end

  match_when_negated do |actual|
    expect(actual.stdout).not_to include("corrected")
  end

  failure_message do |actual|
    ftm "expected to fixed {{italic:#{file}}} in stdout '#{actual.stdout.chomp}'"
  end

  failure_message_when_negated do |actual|
    ftm "expected not to fix {{italic:#{file}}} but got #{file.all_line_changes} '#{actual.stdout.chomp}'"
  end
end

[:untracked, :staged, :tracked].each do |type|
  RSpec::Matchers.alias_matcher :"have_fixed_#{type}_file" , :have_fixed
end
RSpec::Matchers.alias_matcher :have_fixed_file , :have_fixed

# frozen_string_literal: true

RSpec::Matchers.define :list_file do |file|
  match do |actual|
    expect(actual.stdout).to include(file.to_path)
  end

  match_when_negated do |actual|
    expect(actual.stdout).not_to include(file.to_path)
  end

  failure_message do |actual|
    ftm "expected to find {{italic:#{file.to_path}}} {{yellow:in a list}} in stdout '#{actual.stdout.chomp}' '#{actual.stderr.chomp}'"
  end

  failure_message_when_negated do |actual|
    ftm "expected not to find {{italic:#{file.to_path}}} {{yellow:in a list}} in stdout '#{actual.stdout.chomp}'"
  end
end

%i[untracked staged tracked].each do |type|
  RSpec::Matchers.alias_matcher :"have_listed_#{type}_file", :list_file
end

RSpec::Matchers.alias_matcher :have_listed_file, :list_file

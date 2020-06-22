RSpec::Matchers.define :have_files do |*files|
  result = lambda do
    files.all? do |file1|
      Rfix.paths.any? do |file2|
        file2.include?(file1)
      end
    end
  end

  match do |actual|
    result.call
  end

  match_when_negated do |actual|
    !result.call
  end
end

RSpec::Matchers.alias_matcher :have_file , :have_files

RSpec::Matchers.define :have_no_files do |*files|
  result = lambda do
    Rfix.paths.empty?
  end

  match do |actual|
    result.call
  end

  match_when_negated do |actual|
    !result.call
  end
end

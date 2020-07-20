RSpec::Matchers.define :have_no_files do |*_files|
  result = lambda do
    Rfix.paths.empty?
  end

  match do |_actual|
    result.call
  end

  match_when_negated do |_actual|
    !result.call
  end

  def to_relative(path)
    path.sub(File.join(Dir.getwd, "/"), "")
  end

  def act
    return "nothing" if Rfix.paths.empty?

    Rfix.paths.map(&method(:to_relative)).join(", ")
  end

  failure_message do
    "expected no files but got #{act}"
  end

  failure_message_when_negated do
    "expected files but got nothing"
  end
end

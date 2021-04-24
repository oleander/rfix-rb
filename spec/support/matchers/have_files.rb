RSpec::Matchers.define :have_files do |*files|
  extend Rfix::Log

  error_box "#have_file matcher" do
    prt "Are you sure you want to use #have_files?"
  end

  result = lambda do
    files.all? do |file1|
      Rfix.paths.any? do |file2|
        file2.include?(file1)
      end
    end
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
    return "{{warning:nothing}}" if Rfix.paths.empty?

    Rfix.paths.map(&method(:to_relative)).join(", ")
  end

  def fls(files)
    "{{italic:#{files.join(', ')}}}"
  end

  failure_message do
    ftm "expected that rfix would inspect #{fls(files)} but got #{act}"
  end

  failure_message_when_negated do |_actual|
    ftm "expected rfix would not inspect #{fls(files)} but got #{act}"
  end
end

RSpec::Matchers.alias_matcher :have_file, :have_files

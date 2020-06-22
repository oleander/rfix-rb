RSpec::Matchers.define :have_path_count do |expected|
  match do |actual|
    actual.stderr.include?("#{expected} paths")
  end

  # failure_message do |actual|
  #   "expected that stdout would contain '#{expected} paths'"
  # end
end

RSpec::Matchers.define :fix_files_count do |count|
  match do |actual|
    before = no_changed_files
    actual.call
    (before + count) == no_changed_files
  end

  supports_block_expectations
end

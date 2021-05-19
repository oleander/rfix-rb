# frozen_string_literal: true

RSpec.describe Rfix::File::Deleted do
  it_behaves_like "a skipped file", :deleted?
end

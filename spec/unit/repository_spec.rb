RSpec.describe Rfix::Repository do
  let(:test_path) { Pathname(__dir__).join("../../tmp/complex") }
  let(:rugged) { Rugged::Repository.new(test_path) }
  let(:branch) { Rfix::Branch::MAIN }
  subject { described_class.new(repository: rugged, reference: branch) }

  it { is_expected.to have_attributes(paths: []) }
end

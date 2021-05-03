RSpec.describe Rfix::CLI::Command::Branch do
  let(:bundle_path) { Pathname.pwd.join("spec/fixtures/complex.bundle") }
  let(:tmp_path) { Pathname(Dir.mktmpdir) }

  before do
    system "git", "clone", bundle_path.to_s, tmp_path.to_s, "--branch", "master"
  end

  after do
    tmp_path.rmtree
  end

  describe '::call' do
    it 'does not raise an error' do
      Dir.chdir(tmp_path) do
        expect { described_class.new.call(branch: "HEAD", **described_class.default_params) }.not_to raise_error
      end
    end
  end
end

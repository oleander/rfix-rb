RSpec.describe Rfix::CLI::Command::Branch do
  let(:bundle_path) { Pathname.pwd.join("spec/fixtures/complex.bundle") }
  let(:tmp_path) { Pathname(Dir.mktmpdir) }
  let(:params) { described_class.default_params }
  let(:command) { described_class.new }

  before do
    system "git", "clone", bundle_path.to_s, tmp_path.to_s, "--branch", "master"
  end

  after do
    tmp_path.rmtree
  end

  describe '::call' do
    context 'when branch is HEAD' do
      it 'does not correct any files' do
        Dir.chdir(tmp_path) do
          expect { command.call(branch: "master", **params) }.to raise_error(SystemExit) do |error|
            expect(error.status).to eq(0)
          end
        end
      end

      it 'corrects files' do
        Dir.chdir(tmp_path) do
          expect { command.call(branch: "HEAD~5", **params) }.to raise_error(SystemExit) do |error|
            expect(error.status).to eq(1)
          end
        end
      end
    end
  end
end

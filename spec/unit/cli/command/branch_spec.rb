RSpec.describe Rfix::CLI::Command::Branch do
  let(:bundle_path) { Pathname.pwd.join("spec/fixtures/complex.bundle") }
  let(:tmp_path) { Pathname(Dir.mktmpdir) }
  let(:repo_path) { tmp_path.join("repo") }
  let(:params) { described_class.default_params }
  let(:command) { described_class.new }

  describe '::call' do
    context 'when branch is HEAD' do
      before do
        system "mkdir", repo_path.to_s
        system "git", "clone", bundle_path.to_s, repo_path.to_s, "--branch", "master"
      end

      after do
        tmp_path.rmtree
      end

      it 'does not correct any files' do
        Dir.chdir(repo_path) do
          expect(command.call(branch: "master", **params)).to be_a(Integer)
        end
      end

      it 'corrects files' do
        Dir.chdir(repo_path) do
          expect(command.call(branch: "master~15", **params)).to be_a(Integer)
        end
      end
    end
  end
end

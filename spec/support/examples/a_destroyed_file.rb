RSpec.shared_examples "a destroyed file" do
  Change::FIXTURES.keys.each do |type|
    fdescribe "a destroy file of type #{type}" do
      describe "a destroyed file which has not been staged" do
        let(:file) { f(type).tracked.destroy }
        it { is_expected.to have_exit_status(0) }
        it { is_expected.to_not have_listed_file(file) }
        it { is_expected.to_not have_linted_staged_file(file) }
      end

      describe "a destroyed file which is staged" do
        let(:file) { f(type).tracked.destroy.staged }
        it { is_expected.to have_exit_status(0) }
        it { is_expected.to_not have_listed_file(file) }
        it { is_expected.to_not have_linted_staged_file(file) }
      end

      describe "a destroyed file which is tracked" do
        let(:file) { f(type).tracked.destroy.tracked }
        it { is_expected.to have_exit_status(0) }
        it { is_expected.to_not have_listed_file(file) }
        it { is_expected.to_not have_linted_staged_file(file) }
      end
    end
  end
end

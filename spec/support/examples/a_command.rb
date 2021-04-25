# frozen_string_literal: true

RSpec.shared_examples "a command", shared_examples: :metadata do
  describe "no files" do
    it { is_expected.to have_exit_status(0) }
  end

  describe "status code", args: ["--dry"] do
    describe "does not include untracked" do
      describe "invalid untracked file" do
        let(:file) { f(:invalid).untracked }

        it { is_expected.to have_exit_status(0) }
      end

      fdescribe "invalid tracked file", :failure, args: ["--lint"] do
        let(:file) { f(:invalid).tracked }
        # it { is_expected.to have_exit_status(1) }
      end

      describe "valid tracked file" do
        let(:file) { f(:valid).tracked }

        it { is_expected.to have_exit_status(0) }
      end

      describe "valid untracked file" do
        let(:file) { f(:valid).untracked }

        it { is_expected.to have_exit_status(0) }
      end
    end

    describe "does include untracked", args: ["--untracked"] do
      describe "invalid untracked file" do
        let(:file) { f(:invalid).untracked }

        it { is_expected.to have_exit_status(0) }
      end

      describe "invalid tracked file" do
        let(:file) { f(:invalid).tracked }

        it { is_expected.to have_exit_status(0) }
      end

      describe "valid tracked file" do
        let(:file) { f(:valid).tracked }

        it { is_expected.to have_exit_status(0) }
      end

      describe "valid untracked file" do
        let(:file) { f(:valid).untracked }

        it { is_expected.to have_exit_status(0) }
      end
    end
  end

  describe "staged" do
    describe "staged files" do
      describe "invalid", :success do
        let(:file) { f(:invalid).staged }
        # it { is_expected.to have_exit_status(0) }
        # it { is_expected.to have_listed_staged_file(file) }

        it { is_expected.to have_fixed_staged_file(file) }
      end

      describe "valid", :success do
        let(:file) { f(:valid).staged }
        # it { is_expected.to have_exit_status(0) }
        # it { is_expected.to have_listed_staged_file(file) }

        it { is_expected.not_to have_fixed_staged_file(file) }
      end

      describe "unfixable", :failure do
        let(:file) { f(:unfixable).staged }
        # it { is_expected.to have_exit_status(1) }
        # it { is_expected.to have_listed_staged_file(file) }

        it { is_expected.not_to have_fixed_staged_file(file) }
      end

      describe "not_ruby", :success do
        let(:file) { f(:not_ruby).staged }
        # it { is_expected.to have_exit_status(0) }
        # it { is_expected.not_to have_listed_staged_file(file) }

        it { is_expected.not_to have_fixed_staged_file(file) }
      end
    end

    describe "tracked" do
      describe "invalid", :success do
        let(:file) { f(:invalid).tracked.append(:invalid).staged }

        it { is_expected.to have_offenses_for(file) }
        it { is_expected.to have_fixed_staged_file(file) }
      end

      describe "valid", :success do
        let(:file) { f(:valid).tracked.append(:invalid).staged }

        it { is_expected.to have_offenses_for(file) }
        it { is_expected.to have_fixed_staged_file(file) }
      end
    end
  end

  describe "insert" do
    describe "invalid", :success do
      let(:file) { f(:invalid).tracked.insert(:invalid).tracked }

      it { is_expected.to have_offenses_for(file) }
      it { is_expected.to have_fixed_file(file) }
    end

    describe "valid to invalid", :success do
      let(:file) { f(:valid).tracked.insert(:invalid).tracked }

      it { is_expected.to have_offenses_for(file) }
      it { is_expected.to have_fixed_file(file) }
    end

    describe "invalid to valid", :success do
      let(:file) { f(:invalid).tracked }

      it { is_expected.to have_offenses_for(file) }
      it { is_expected.to have_fixed_file(file) }
    end

    describe "valid to valid" do
      let(:file) { f(:valid).tracked.insert(:valid).tracked }

      it { is_expected.not_to have_offenses_for(file) }
      it { is_expected.not_to have_fixed_file(file) }
    end
  end

  describe "tracked" do
    describe "invalid -> delete(invalid)", :success do
      let(:file) { f(:invalid).tracked.delete(:invalid).tracked }

      it { is_expected.not_to have_offenses_for(file) }
      it { is_expected.not_to have_fixed_file(file) }
    end

    describe "invalid -> delete(valid)", :success do
      let(:file) { f(:valid).tracked.delete(:valid).tracked }

      it { is_expected.not_to have_offenses_for(file) }
      it { is_expected.not_to have_fixed_file(file) }
    end

    describe "invalid -> delete(invalid) & delete(valid)", :success do
      let(:file) { f(:valid).tracked.insert(:invalid).insert(:valid).tracked.delete(:invalid).delete(:valid).tracked }

      it { is_expected.not_to have_offenses_for(file) }
      it { is_expected.not_to have_fixed_file(file) }
    end

    describe "combining insert & delete", :success do
      let(:file) { f(:invalid).insert(:valid, 2).delete(:valid).tracked }

      it { is_expected.to have_offenses_for(file) }
      it { is_expected.to have_fixed_file(file) }
    end
  end

  describe "untracked", args: ["--untracked"] do
    describe "invalid -> delete(invalid)", :success do
      let(:file) { f(:invalid).delete(:invalid) }

      it { is_expected.not_to have_offenses_for(file) }
      it { is_expected.not_to have_fixed_file(file) }
    end

    describe "invalid -> delete(valid)", :success do
      let(:file) { f(:valid).delete(:valid) }

      it { is_expected.not_to have_offenses_for(file) }
      it { is_expected.not_to have_fixed_file(file) }
    end

    describe "invalid -> delete(invalid) & delete(valid)", :success do
      let(:file) { f(:valid).insert(:invalid).insert(:valid).delete(:invalid).delete(:valid) }

      it { is_expected.not_to have_offenses_for(file) }
      it { is_expected.not_to have_fixed_file(file) }
    end

    describe "combining insert & delete", :success do
      let(:file) { f(:invalid).insert(:valid, 2).delete(:valid) }

      it { is_expected.to have_offenses_for(file) }
      it { is_expected.to have_fixed_file(file) }
    end
  end

  describe "untracked with no flag" do
    describe "invalid -> delete(invalid)", :success do
      let(:file) { f(:invalid).delete(:invalid) }

      it { is_expected.not_to have_offenses_for(file) }
      it { is_expected.not_to have_fixed_file(file) }
    end

    describe "invalid -> delete(valid)", :success do
      let(:file) { f(:valid).delete(:valid) }

      it { is_expected.not_to have_offenses_for(file) }
      it { is_expected.not_to have_fixed_file(file) }
    end

    describe "invalid -> delete(invalid) & delete(valid)", :success do
      let(:file) { f(:valid).insert(:invalid).insert(:valid).delete(:invalid).delete(:valid) }

      it { is_expected.not_to have_offenses_for(file) }
      it { is_expected.not_to have_fixed_file(file) }
    end

    describe "combining insert & delete", :success do
      let(:file) { f(:invalid).insert(:valid, 2).delete(:valid) }

      it { is_expected.not_to have_offenses_for(file) }
      it { is_expected.not_to have_fixed_file(file) }
    end

    describe "changed tracked files" do
      describe "invalid -> delete(invalid)" do
        let(:file) { f(:invalid).tracked.delete(:invalid) }
        # it { is_expected.to have_listed_file(file) }

        it { is_expected.not_to have_fixed_file(file) }
      end

      describe "invalid -> delete(valid)" do
        let(:file) { f(:valid).tracked.delete(:valid) }
        # it { is_expected.to have_listed_file(file) }

        it { is_expected.not_to have_fixed_file(file) }
      end

      describe "combining insert & delete" do
        let(:file) { f(:invalid).tracked.insert(:valid, 2).delete(:valid) }
        # it { is_expected.to have_listed_file(file) }

        it { is_expected.to have_fixed_file(file) }
      end
    end
  end
end

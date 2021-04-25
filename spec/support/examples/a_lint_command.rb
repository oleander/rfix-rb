# frozen_string_literal: true

RSpec.shared_examples "a lint command" do
  describe "staged" do
    describe "staged files" do
      describe "invalid", :failure do
        let(:file) { f(:invalid).staged }

        it { is_expected.to have_offenses_for(file) }
        it { is_expected.to have_linted_staged_file(file) }
      end

      describe "valid", :success do
        let(:file) { f(:valid).staged }

        it { is_expected.not_to have_offenses_for(file) }
        it { is_expected.not_to have_offenses_for(file) }
      end

      describe "unfixable", :failure do
        let(:file) { f(:unfixable).staged }

        it { is_expected.to have_offenses_for(file) }
        it { is_expected.to have_linted_staged_file(file) }
      end

      describe "not ruby", :success do
        let(:file) { f(:not_ruby).staged }

        it { is_expected.not_to have_offenses_for(file) }
        it { is_expected.not_to have_linted_staged_file(file) }
      end
    end

    describe "tracked & staged" do
      describe "invalid", :failure do
        let(:file) { f(:invalid).tracked.append.staged }

        it { is_expected.to have_offenses_for(file) }
      end

      describe "valid", :failure do
        let(:file) { f(:valid).tracked.append.staged }

        it { is_expected.to have_offenses_for(file) }
      end

      describe "unfixable", :failure do
        let(:file) { f(:unfixable).tracked.append.staged }

        it { is_expected.to have_offenses_for(file) }
      end

      describe "not ruby", :success do
        let(:file) { f(:not_ruby).tracked }

        it { is_expected.not_to have_offenses_for(file) }
      end
    end
  end

  describe "tracked files" do
    describe "invalid", :failure do
      let(:file) { f(:invalid).tracked }

      it { is_expected.to have_linted_tracked_file(file) }
      it { is_expected.to have_offenses_for(file) }
    end

    describe "valid", :success do
      let(:file) { f(:valid).tracked }

      it { is_expected.not_to have_offenses_for(file) }
      it { is_expected.to have_linted_tracked_file(file) }
    end

    describe "unfixable", :failure do
      let(:file) { f(:unfixable).tracked }

      it { is_expected.to have_offenses_for(file) }
      it { is_expected.to have_linted_tracked_file(file) }
    end

    describe "not ruby", :success do
      let(:file) { f(:not_ruby).tracked }

      it { is_expected.not_to have_offenses_for(file) }
      it { is_expected.not_to have_linted_tracked_file(file) }
    end
  end

  describe "untracked files" do
    describe "invalid", :failure do
      let(:file) { f(:invalid).untracked }

      it { is_expected.to have_offenses_for(file) }
      it { is_expected.to have_linted_tracked_file(file) }
    end

    describe "valid", :success do
      let(:file) { f(:valid).tracked }

      it { is_expected.not_to have_offenses_for(file) }
      it { is_expected.to have_linted_tracked_file(file) }
    end

    describe "unfixable", :failure do
      let(:file) { f(:unfixable).untracked }

      it { is_expected.to have_offenses_for(file) }
      it { is_expected.to have_linted_tracked_file(file) }
    end

    describe "not ruby", :success do
      let(:file) { f(:not_ruby).tracked }

      it { is_expected.not_to have_offenses_for(file) }
      it { is_expected.not_to have_linted_tracked_file(file) }
    end
  end

  describe "grouped files" do
    describe "untracked files mixed with tracked files", :failure do
      let(:file1) { f(:invalid).tracked }
      let(:file2) { f(:invalid).untracked }
      let(:file3) { f(:valid).tracked }
      let(:file4) { f(:valid).tracked }

      it { is_expected.to have_offenses_for(file1) }
      it { is_expected.to have_linted(file1) }

      it { is_expected.to have_offenses_for(file2) }
      it { is_expected.to have_linted(file2) }
      #
      # it { is_expected.not_to have_offenses_for(file3) }
      # it { is_expected.not_to have_linted(file3) }
      #
      # it { is_expected.not_to have_offenses_for(file4) }
      # it { is_expected.to have_linted(file4) }
    end

    describe "tracked files", :failure do
      let(:file1) { f(:invalid).tracked }
      let(:file2) { f(:invalid).untracked }
      let(:file3) { f(:valid).tracked }
      let(:file4) { f(:valid).tracked }

      it { is_expected.to have_offenses_for(file1) }
      it { is_expected.to have_linted(file1) }

      it { is_expected.to have_offenses_for(file2) }
      it { is_expected.to have_linted(file2) }

      it { is_expected.not_to have_offenses_for(file3) }
      it { is_expected.not_to have_fixed(file3) }

      it { is_expected.not_to have_offenses_for(file4) }
      it { is_expected.not_to have_fixed(file4) }
    end
  end
end

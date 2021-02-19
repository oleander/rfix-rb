RSpec.describe Rfix::Indentation do
  context "with extra indentation" do
    subject { described_class.new(input, extra_indentation: 1) }

    describe "#stripped" do
      context "given two lines" do
        context "given two tabs" do
          let(:input) do
            <<~CODE
              \t\tA
              \tB
            CODE
          end

          its(:stripped) { is_expected.to eq(" \tA\n B\n") }
        end
      end

      context "given one line" do
        context "given two tabs" do
          let(:input) do
            <<~CODE
              \t\tA
            CODE
          end

          its(:stripped) { is_expected.to eq(" A\n") }
        end

        context "given no indentation" do
          let(:input) do
            <<~CODE
              A
            CODE
          end

          its(:stripped) { is_expected.to eq(" A\n") }
        end
      end

      context "given two lines" do
        context "given no indentation" do
          let(:input) do
            <<~CODE
              A
              B
            CODE
          end

          its(:stripped) { is_expected.to eq(" A\n B\n") }
        end
      end
    end
  end

  context "w/o extra indentation" do
    subject { described_class.new(input) }

    describe "#stripped" do
      context "given one line" do
        context "given no indentation" do
          let(:input) do
            <<~CODE
              A
            CODE
          end

          its(:stripped) { is_expected.to eq(input) }
        end

        context "given two tabs" do
          let(:input) do
            <<~CODE
              \t\tA
            CODE
          end

          its(:stripped) { is_expected.to eq("A\n") }
        end
      end

      context "given two lines" do
        context "given no indentation" do
          let(:input) do
            <<~CODE
              A
              B
            CODE
          end

          its(:stripped) { is_expected.to eq(input) }
        end

        context "given two tabs" do
          let(:input) do
            <<~CODE
              \t\tA
              \tB
            CODE
          end

          its(:stripped) { is_expected.to eq("\tA\nB\n") }
        end
      end
    end

    describe "#min_indentation" do
      context "given no lines" do
        context "given no indentation" do
          let(:input) do
            ""
          end

          its(:min_indentation) { is_expected.to eq(0) }
        end
      end

      context "given one line" do
        context "given no indentation" do
          let(:input) do
            <<~CODE
              A
            CODE
          end

          its(:min_indentation) { is_expected.to eq(0) }
        end

        context "given two tabs" do
          let(:input) do
            <<~CODE
              \t\tA
            CODE
          end

          its(:min_indentation) { is_expected.to eq(2) }
        end
      end

      context "given two line" do
        context "given no indentation" do
          let(:input) do
            <<~CODE
              A
              B
            CODE
          end

          its(:min_indentation) { is_expected.to eq(0) }
        end

        context "given two tabs" do
          let(:input) do
            <<~CODE
              \tA
              \t\tB
              \t\t\tC
            CODE
          end

          its(:min_indentation) { is_expected.to eq(1) }
        end
      end
    end
  end
end

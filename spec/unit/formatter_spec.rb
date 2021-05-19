# frozen_string_literal: true

require "stringio"
require "tempfile"
require "parser/current"

RSpec.describe Rfix::Formatter, type: :aruba do
  subject(:formatter) { described_class.new(io, {}) }

  let(:io) { StringIO.new }
  let(:file) { Blob.new(name: "example.rb", path: expand_path("repository")) }
  let(:ruby) do
    <<~RUBY
      def hello(*args)
        puts "OK"
      end
    RUBY
  end
  let(:buffer) { Parser::Source::Buffer.new(file.absolute_path.to_s, source: ruby) }
  let(:location) { Parser::Source::Range.new(buffer, 21, 35) }
  let(:message) { "Favor `format` over `String#%`" }
  let(:severity) { RuboCop::Cop::Severity.name_from_code("E") }
  let(:offense) do
    RuboCop::Cop::Offense.new(severity, location, message, "Style/FormatString")
  end

  let(:offenses) { [offense] }
  let(:icon) { "icon" }
  let(:msg) { "msg" }

  describe "#started" do
    context "with files" do
      it "wont raise error" do
        expect { formatter.started([file]) }.not_to raise_error
      end
    end

    context "without files" do
      it "wont raise error" do
        expect { formatter.started([]) }.not_to raise_error
      end
    end
  end

  describe "#file_finished" do
    context "without offenses" do
      it "wont raise error" do
        expect { formatter.file_finished(file, []) }.not_to raise_error
      end
    end

    context "with offenses" do
      it "wont raise error" do
        expect { formatter.file_finished(file, offenses) }.not_to raise_error
      end
    end
  end

  describe "#finished" do
    context "with files" do
      it "wont raise error" do
        formatter.started([file])
        formatter.file_finished(file, offenses)
        expect { formatter.finished([file]) }.not_to raise_error
      end
    end

    context "without files" do
      it "wont raise error" do
        expect { formatter.finished([]) }.not_to raise_error
      end
    end
  end
end

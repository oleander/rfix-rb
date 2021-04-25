# frozen_string_literal: true

require "cli/ui"

module Rfix
  class Indicator
    include Dry::Core::Constants

    def initialize
      @condition = ConditionVariable.new
      @group = ::CLI::UI::SpinGroup.new
      @threads = EMPTY_ARRAY.dup
      @mutex = Mutex.new
    end

    def start(title)
      if started?
        raise Error, "Already started"
      end

      @group.add(title) do
        @mutex.synchronize do
          @condition.wait(@mutex)
        end
      end

      @threads << Thread.new do
        @group.wait
      end
    end

    def stop
      return if stopped?

      Thread.new do
        @mutex.synchronize do
          @condition.signal
        end
      end.join
    end

    private

    def stopped?
      @threads.none?(&:alive?)
    end

    def started?
      @threads.any?
    end
  end
end

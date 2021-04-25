# frozen_string_literal: true

require "git"

module ::Git
  class Base
    def dirty?
      status.dirty?
    end

    def dump!
      status.dump!
    end
  end

  class Status
    include Rfix::Log

    def dirty?
      number_of_dirty_files > 0
    end

    def number_of_dirty_files
      [changed, untracked, added, deleted].flatten.reduce(0) do |acc, status|
        acc + status.keys.length
      end
    end

    def dump!
      box("#{dump_icon} Git Status (#{number_of_dirty_files})") do
        prt pretty
          .gsub("untrac true", "{{x}} {{red:not tracked}}")
          .gsub("untrac", "{{v}} {{green:tracked}}").chomp
      end
    end

    def dump_icon
      dirty? ? "{{x}}" : "{{v}}"
    end
  end
end

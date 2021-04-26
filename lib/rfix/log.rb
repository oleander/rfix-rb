# frozen_string_literal: true

module Rfix
  module Log
    module_function

    def say(message)
      prt("{{v}} #{message}")
    end

    def say_error(message)
      prt("{{x}} #{message}")
    end
    alias say! say_error

    def say_error_sub(message)
      prt(message.to_s)
    end

    def error_box(title, &block)
      box(title, color: :red, &block)
    end

    def abort_box(title, &block)
      error_box(title, &block)
      exit 1
    end

    def say_test(message)
      prt("{{i}} #{strip(message)}")
    end

    def say_debug(message)
      if debug? || test?
        prt("{{i}} #{strip(message)}", to: $stderr)
      end
    end

    def say_abort(message)
      prt("{{x}} #{message}")
      exit 1
    end

    def debug?
      return false unless defined?(RSpec)

      RSpec.configuration.debug?
    end

    def test?
      # Rfix.test?
      false
    end

    def say_exit(message)
      prt("{{v}} #{message}")
      exit 0
    end

    def say_plain(message)
      prt(message)
    end

    def debug_box(title, &block)
      unless_debug do
        box(title, &block)
      end
    end

    def prt(*args)
      ::CLI::UI.puts(*args)
    end

    def fmt(*args)
      ::CLI::UI.fmt(*args)
    end

    alias ftm fmt

    def log_items(items, title:)
      box("#{title} (#{items.count})") do
        if items.empty?
          return margin(2) do
            prt "{{warning:No items found}}"
          end
        end

        items.each do |item|
          if block_given?
            say strip(yield item)
          else
            say strip(item.to_s)
          end
        end
      end
    end

    def box(title, color: :reset, &block)
      margin do
        ::CLI::UI::Frame.open(title, color: color) do
          margin(2, &block)
        end
      end
    end

    def strip(msg)
      msg
      # msg.gsub(current_path, "").gsub(Dir.pwd, ".").chomp
    end

    def current_path
      File.join(Dir.pwd, "/")
    end

    def div(title, **args, &block)
      ::CLI::UI::Frame.divider(title, **args)
      margin(&block)
    end

    def margin(number_of_new_lines = 1)
      new_line(number_of_new_lines)
      yield
      new_line(number_of_new_lines)
    end

    def new_line(number_of_new_lines = 1)
      say_plain("\n" * number_of_new_lines)
    end

    def unless_debug
      yield unless Rfix.debug?
    end
  end
end

# frozen_string_literal: true

require "rfix"
require "cli/ui"

module Rfix::Log
  extend self
  def say(message)
    prt("{{v}} #{message}")
  end

  def say_error(message)
    prt("{{x}} #{message}")
  end

  def say_error_sub(message)
    prt(message.to_s)
  end

  def error_box(title)
    box(title, color: :red) { yield }
  end

  def abort_box(title)
    error_box(title) { yield }
    exit 1
  end

  def say_debug(message)
    unless_debug do
      prt("{{i}} #{strip(message)}")
    end
  end

  def say_abort(message)
    prt("{{x}} #{message}")
    exit 1
  end

  def say_exit(message)
    prt("{{v}} #{message}")
    exit 0
  end

  def say_plain(message)
    prt(message)
  end

  def debug_box(title)
    unless_debug do
      box(title) { yield }
    end
  end

  def prt(*args)
    CLI::UI.puts(*args)
  end

  def log_items(items, title:)
    box("#{title} (#{items.count})") do
      return margin(2) do
        prt "{{warning:No items found}}"
      end if items.empty?

      items.each do |item|
        if block_given?
          say strip(yield item)
        else
          say strip(item.to_s)
        end
      end
    end
  end

  def box(title, color: :reset)
    margin do
      CLI::UI::Frame.open(title, color: color) do
        margin(2) do
          yield
        end
      end
    end
  end

  def strip(msg)
    msg.gsub(current_path, "").gsub(Dir.pwd, ".").chomp
  end

  def current_path
    File.join(Dir.pwd, "/")
  end

  def div(title)
    CLI::UI::Frame.divider(title)
    margin { yield }
  end

  def margin(n = 1)
    new_line(n)
    yield
    new_line(n)
  end

  def new_line(n = 1)
    say_plain("\n" * n)
  end

  def unless_debug
    yield unless Rfix.debug?
  end
end

# frozen_string_literal: true

require "rfix"
require "cli/ui"

module Rfix::Log
  def say(message)
    CLI::UI.puts("{{v}} #{message}")
  end

  def say_error(message)
    CLI::UI.puts("{{x}} #{message}")
  end

  def say_error_sub(message)
    CLI::UI.puts(message.to_s)
  end

  def say_debug(message)
    if Rfix.debug?
      CLI::UI.puts("{{*}} [{{info:Debug}}] #{message}")
    end
  end

  def say_abort(message)
    CLI::UI.puts("{{x}} #{message}")
    exit 1
  end

  def say_exit(message)
    CLI::UI.puts("{{v}} #{message}")
    exit 0
  end
end

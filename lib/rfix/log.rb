# frozen_string_literal: true

require "tty/box"
require "tty/prompt"
require "tty/screen"

module Rfix
  module Log
    module_function

    def prompt
      @prompt ||= TTY::Prompt.new
    end

    def say(message)
      prompt.ok(message)
    end

    def say!(message)
      prompt.warn(message)
    end
  end
end

# frozen_string_literal: true

module Rfix
  module FileSetup
    def meta_to_args(keys)
      keys.each_with_object({}) do |key, acc|
        acc[key] = true
      end
    end

    def load_args(example)
      meta_to_args(example.metadata.fetch(:args, []))
    end

    def init_file(file)
      public_send(file.to_sym)
    rescue NoMethodError
      nil
    end

    def load_file(file)
      init_file(file).tap do |file_obj|
        file_obj&.write!
      end
    end

    def setup_files!(order = 1)
      # say_debug("Setup file {{warning:#{order}}}")

      if order == 1
        load_file("file")
      end

      if load_file("file#{order}")
        setup_files!(order + 1)
      end
    end
  end
end

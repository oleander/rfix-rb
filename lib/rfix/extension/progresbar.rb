require "tty/progressbar"

module TTY
  class ProgressBar
    concerning :Log, prepend: true do
      def log(input)
        input.each_line do |line|
          super(line.strip)
        end
      end
    end
  end
end

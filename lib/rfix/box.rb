class Rfix::Box < Struct.new(:out, :err, :status, :args, :quiet)
  include Rfix::Log

  def render(color: :reset, debug: false)
    return if Rfix.debug? && !debug

    @render ||= box(title, color: color) do
      margin do
        prt cmd_lines
      end

      div("{{info:STDOUT}}") do
        prt lines_or_none(stdout)
      end

      div("{{error:STDERR}}") do
        prt lines_or_none(stderr)
      end
    end
  end

  def lines_or_none(lines)
    if lines.join.chomp.empty?
      return "{{italic:<none>}}"
    end

    lines.map(&method(:strip)).join("\n")
  end

  def title
    "#{quiet_icon}#{icon} #{bin} (#{exit_status}) @ {{italic:#{pwd}}}"
  end

  def quiet_icon
    return "" unless quiet

    "{{warning:[silent]}} "
  end

  def stdout
    @stdout ||= dumpable(out.lines.map(&:chomp))
  end

  def stderr
    @stderr ||= dumpable(err.lines.map(&:chomp))
  end

  def dumpable(lines)
    box = self
    lines.tap do
      lines.define_singleton_method(:dump!) do
        tap do
          box.render
        end
      end
    end
  end

  def icon
    success? ? "{{v}}" : "{{x}}"
  end

  def success?
    status.success?
  end

  def bin
    clean_args.first
  end

  def tail
    clean_args[1..-1]
  end

  def exit_status
    status.exitstatus
  end

  def pwd
    if Dir.getwd == Dir.pwd
      return "{{italic:#{Dir.getwd}}}"
    end

    Dir.getwd.sub(Dir.pwd, "")
  end

  private

  def longest_arg
    @longest_arg ||= clean_args.reduce(0) do |acc, arg|
      acc < arg.length ? arg.length : acc
    end
  end

  def clean_args
    @clean_args ||= args.map(&method(:strip))
  end

  def rest
    tail.each_slice(2).map do |args|
      args.map do |arg|
        arg.ljust(longest_arg + 5)
      end.join(" ")
    end.map do |tail|
      "  {{italic:#{tail}}}"
    end.join("\n")
  end

  def cmd_lines
    "{{command:$ #{bin} \n#{rest}}}"
  end
end

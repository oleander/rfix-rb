RuboCop::Options.new.opts.instance_eval("@stack", __FILE__, __LINE__).map(&:list).flatten.each do |opt|
  short = opt.short.map { |arg| arg.delete_prefix("-") }
  long = opt.long.map { |arg| arg.delete_prefix("--") }

  short.unshift(nil) if opt.short.empty?
  long.unshift(nil) if opt.long.empty?

  if opt.arg
    option(*short, *long, opt.desc.join(" "), argument: :optional) do |value|
      r_args.append(*opt.long, value)
    end
  else
    flag(*short, *long, opt.desc.join(" ")) do
      r_args.append(*opt.long)
    end
  end
end

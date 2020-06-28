module Rfix::Ext::Opt
  def define_options
    @define_options ||= super
  end
  alias opts define_options
end

RuboCop::Options.prepend(Rfix::Ext::Opt)

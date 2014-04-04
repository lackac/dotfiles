extend_console "looksee", RUBY_ENGINE != "macruby" do

  require 'looksee/shortcuts'

  Looksee.styles = {
    :module     => "\e[30m%s\e[0m",
    :public     => "\e[34m%s\e[0m",
    :protected  => "\e[35m%s\e[0m",
    :private    => "\e[31m%s\e[0m",
    :undefined  => "\e[36m%s\e[0m",
    :overridden => "\e[33m%s\e[0m"
  }

  tip "use `some_object.ls' to see the lookup path of the object"

end

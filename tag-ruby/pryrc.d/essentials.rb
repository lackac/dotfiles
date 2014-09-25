# set RUBY_ENGINE if undefined
RUBY_ENGINE = "ruby" unless defined?(RUBY_ENGINE)

ANSI = {}
ANSI[:RESET]     = "\e[0m"
ANSI[:BOLD]      = "\e[1m"
ANSI[:UNDERLINE] = "\e[4m"
ANSI[:LGRAY]     = "\e[0;37m"
ANSI[:GRAY]      = "\e[1;30m"
ANSI[:RED]       = "\e[31m"
ANSI[:GREEN]     = "\e[32m"
ANSI[:YELLOW]    = "\e[33m"
ANSI[:BLUE]      = "\e[34m"
ANSI[:MAGENTA]   = "\e[35m"
ANSI[:CYAN]      = "\e[36m"
ANSI[:WHITE]     = "\e[37m"

# Loading extensions of the console. This is wrapped
# because some might not be included in your Gemfile
# and errors will be raised
def extend_console(name, care = true, needs_require = true)
  if care
    require name if needs_require
    yield if block_given?
    $console_extensions << "#{ANSI[:GREEN]}#{name}#{ANSI[:RESET]}"
  else
    $console_extensions << "#{ANSI[:GRAY]}#{name}#{ANSI[:RESET]}"
  end
rescue Exception => e
  puts "Error loading #{name}: #{ANSI[:RED]}#{$!}#{ANSI[:RESET]}"
  $console_extensions << "#{ANSI[:RED]}#{name}#{ANSI[:RESET]}"
end
$console_extensions = []


IRB_MOTD = [
  "use Rack::Shell for a rails like console"
]

def tip(new_tip = nil)
  if new_tip.nil?
    tip = IRB_MOTD[rand(IRB_MOTD.size)]
    puts "#{ANSI[:CYAN]}Tip#{ANSI[:RESET]}: #{ANSI[:BOLD]}#{tip}#{ANSI[:RESET]}"
  else
    IRB_MOTD << new_tip
  end
end

extend_console 'pry-doc'

extend_console 'hirb' do
  Hirb::View.instance_eval do
    def enable_output_method
      @output_method = true
      @old_print = Pry.config.print
      Pry.config.print = proc do |*args|
        Hirb::View.view_or_page_output(args[1]) || @old_print.call(*args)
      end
    end

    def disable_output_method
      Pry.config.print = @old_print
      @output_method = nil
    end
  end

  Hirb.enable

  tip "table User.all, :fields => [:id, :name, :email]"
end

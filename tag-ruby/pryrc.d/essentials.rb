# set RUBY_ENGINE if undefined
RUBY_ENGINE = "ruby" unless defined?(RUBY_ENGINE)

ANSI_CODES = {}
ANSI_CODES[:RESET]     = "\e[0m"
ANSI_CODES[:BOLD]      = "\e[1m"
ANSI_CODES[:UNDERLINE] = "\e[4m"
ANSI_CODES[:LGRAY]     = "\e[0;37m"
ANSI_CODES[:GRAY]      = "\e[1;30m"
ANSI_CODES[:RED]       = "\e[31m"
ANSI_CODES[:GREEN]     = "\e[32m"
ANSI_CODES[:YELLOW]    = "\e[33m"
ANSI_CODES[:BLUE]      = "\e[34m"
ANSI_CODES[:MAGENTA]   = "\e[35m"
ANSI_CODES[:CYAN]      = "\e[36m"
ANSI_CODES[:WHITE]     = "\e[37m"

# Loading extensions of the console. This is wrapped
# because some might not be included in your Gemfile
# and errors will be raised
def extend_console(name, care = true, needs_require = true)
  if care
    require name if needs_require
    yield if block_given?
    $console_extensions << "#{ANSI_CODES[:GREEN]}#{name}#{ANSI_CODES[:RESET]}"
  else
    $console_extensions << "#{ANSI_CODES[:GRAY]}#{name}#{ANSI_CODES[:RESET]}"
  end
rescue Exception => e
  puts "Error loading #{name}: #{ANSI_CODES[:RED]}#{$!}#{ANSI_CODES[:RESET]}"
  $console_extensions << "#{ANSI_CODES[:RED]}#{name}#{ANSI_CODES[:RESET]}"
end
$console_extensions = []


IRB_MOTD = [
  "use Rack::Shell for a rails like console"
]

def tip(new_tip = nil)
  if new_tip.nil?
    tip = IRB_MOTD[rand(IRB_MOTD.size)]
    puts "#{ANSI_CODES[:CYAN]}Tip#{ANSI_CODES[:RESET]}: #{ANSI_CODES[:BOLD]}#{tip}#{ANSI_CODES[:RESET]}"
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

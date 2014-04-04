require 'yaml'

# set RUBY_ENGINE if undefined
RUBY_ENGINE = "ruby" unless defined?(RUBY_ENGINE)

# Some of the following is borrowed from Iain Hecker, http://iain.nl
alias q exit

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

# Build a simple colorful IRB prompt
IRB.conf[:PROMPT][:SIMPLE_COLOR] = {
  :PROMPT_I => "#{ANSI[:BLUE]}>>#{ANSI[:RESET]} ",
  :PROMPT_N => "#{ANSI[:BLUE]}>>#{ANSI[:RESET]} ",
  :PROMPT_C => "#{ANSI[:RED]}?>#{ANSI[:RESET]} ",
  :PROMPT_S => "#{ANSI[:YELLOW]}?>#{ANSI[:RESET]} ",
  :RETURN   => "#{ANSI[:GREEN]}=>#{ANSI[:RESET]} %s\n",
  :AUTO_INDENT => true }
IRB.conf[:PROMPT_MODE] = :SIMPLE_COLOR

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


extend_console 'wirble' do
  Wirble.init :skip_shortcuts => true
  Wirble.colorize
end

extend_console 'hirb' do
  Hirb.enable
  extend Hirb::Console

  tip "table User.all, :fields => [:id, :name, :email]"
end

extend_console 'g'

extend_console 'ap' do
  alias pp ap
end

extend_console 'interactive_editor'

extend_console "sketches" do
  Sketches.config :editor => 'mate'

  tip "use the sketch method for more complicated hacking in irb"
end

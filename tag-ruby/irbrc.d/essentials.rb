require 'yaml'

# set RUBY_ENGINE if undefined
RUBY_ENGINE = "ruby" unless defined?(RUBY_ENGINE)

# Some of the following is borrowed from Iain Hecker, http://iain.nl
alias q exit

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

# Build a simple colorful IRB prompt
IRB.conf[:PROMPT][:SIMPLE_COLOR] = {
  :PROMPT_I => "#{ANSI_CODES[:BLUE]}>>#{ANSI_CODES[:RESET]} ",
  :PROMPT_N => "#{ANSI_CODES[:BLUE]}>>#{ANSI_CODES[:RESET]} ",
  :PROMPT_C => "#{ANSI_CODES[:RED]}?>#{ANSI_CODES[:RESET]} ",
  :PROMPT_S => "#{ANSI_CODES[:YELLOW]}?>#{ANSI_CODES[:RESET]} ",
  :RETURN   => "#{ANSI_CODES[:GREEN]}=>#{ANSI_CODES[:RESET]} %s\n",
  :AUTO_INDENT => true }
IRB.conf[:PROMPT_MODE] = :SIMPLE_COLOR

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

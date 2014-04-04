def re(string_or_re=nil,the_other=nil)
  return @_re_string if string_or_re == :string
  return @_re_regexp if [:re, :regexp].include?(string_or_re)

  case string_or_re
  when String
    @_re_string = string_or_re
  when Regexp
    @_re_regexp = string_or_re
  when :debug
    debug = true
  end
  return re(the_other) unless the_other.nil?

  capture_colors = [2,4,5,6,3,1]

  if @_re_string and @_re_regexp
    chrismas_tree = @_re_string.gsub(@_re_regexp) do |m|
      stack = []
      beginnings, endings = (1..($~.length-1)).map {|i| $~.offset(i)}.transpose
      beginnings.sort!.map! {|i| i - $~.begin(0)}
      endings.sort!.map! {|i| i - $~.begin(0)}
      if beginnings.nil?
        "\e[32m\e[1m#{m}\e[0m"
      else
        "".tap do |r|
          r << "\e[32m\e[1m"
          m.each_char.each_with_index do |char, i|
            puts "#{char}, #{i} (#{beginnings.inspect}, #{endings.inspect}, #{stack.inspect})" if debug
            while beginnings.first == i
              stack.unshift(beginnings.shift)
              r << "\e[3#{capture_colors[stack.size]}m"
            end
            while endings.first == i
              stack.shift
              r << "\e[3#{capture_colors[stack.size]}m"
              endings.shift
            end
            r << char
          end
          r << "\e[0m"
        end
      end
    end
    puts chrismas_tree
  end
end

tip 'Use the #re method to play with regular expressions'

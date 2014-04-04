# String#to_proc from http://weblog.raganwald.com/2007/10/stringtoproc.html
class String
  unless ''.respond_to?(:to_proc)
    def to_proc &block
      params = []
      expr = self
      sections = expr.split(/\s*->\s*/m)
      if sections.length > 1 then
        eval sections.reverse!.inject { |e, p| "(Proc.new { |#{p.split(/\s/).join(', ')}| #{e} })" }, block && block.binding
      elsif expr.match(/\b_\b/)
        eval "Proc.new { |_| #{expr} }", block && block.binding
      else
        leftSection = expr.match(/^\s*(?:[+*\/%&|\^\.=<>\[]|!=)/m)
        rightSection = expr.match(/[+\-*\/%&|\^\.=<>!]\s*$/m)
        if leftSection || rightSection then
          if (leftSection) then
            params.push('$left')
            expr = '$left' + expr
          end
          if (rightSection) then
            params.push('$right')
            expr = expr + '$right'
          end
        else
          self.gsub(
            /(?:\b[A-Z]|\.[a-zA-Z_$])[a-zA-Z_$\d]*|[a-zA-Z_$][a-zA-Z_$\d]*:|self|arguments|'(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*"/, ''
          ).scan(
            /([a-z_$][a-z_$\d]*)/i
          ) do |v|
            params.push(v) unless params.include?(v)
          end
        end
        eval "Proc.new { |#{params.join(', ')}| #{expr} }", block && block.binding
      end
    end
  end
end

tip "(1..5).map &'*2' # => [2, 4, 6, 8, 10]"

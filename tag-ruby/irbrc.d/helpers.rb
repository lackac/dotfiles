# encoding: UTF-8

module IRBHelpers
  def aabc(n=7)
    ("a".."z").take(n)
  end
  def a123(n=3)
    %w{
      egy kettő három négy öt hat hét nyolc kilenc tíz tizenegy
      tizenkettő tizenhárom tizennégy tizenöt tizenhat tizenhét
      tizennyolc tizenkilenc húsz huszonegy huszonkettő huszonhárom
      huszonnégy huszonöt huszonhat huszonhét huszonnyolc huszonkilenc
      harminc
    }.take(n)
  end
  def habc(n=7)
    Hash[*aabc(n).map {|k| k.to_sym}.zip(aabc(n).map {|v| v.upcase}).flatten]
  end
  def h123(n=3)
    keys = %w{
      one two three four five six seven eight nine ten eleven twelve
      thirteen fourteen fifteen sixteen seventeen eighteen nineteen
      twenty-one twenty-two twenty-three twenty-four twenty-five
      twenty-six twenty-seven twenty-eight twenty-nine thirty
    }.take(n)
    Hash[*keys.map {|k| k.to_sym}.zip(a123(n)).flatten]
  end

  def lorem
    <<-EOH
Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam
nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat
volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation
ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat.
Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse
molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero
eros et accumsan et iusto odio dignissim qui blandit praesent luptatum
zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber
tempor cum soluta nobis eleifend option congue nihil imperdiet doming id
quod mazim placerat facer possim assum. Typi non habent claritatem
insitam; est usus legentis in iis qui facit eorum claritatem.
Investigationes demonstraverunt lectores legere me lius quod ii legunt
saepius. Claritas est etiam processus dynamicus, qui sequitur mutationem
consuetudium lectorum. Mirum est notare quam littera gothica, quam nunc
putamus parum claram, anteposuerit litterarum formas humanitatis per
seacula quarta decima et quinta decima. Eodem modo typi, qui nunc nobis
videntur parum clari, fiant sollemnes in futurum.
    EOH
  end

  def arviz
    "árvíztűrő tükörfúrógép ÁRVÍZTŰRŐ TÜKÖRFÚRÓGÉP"
  end

  def conn
    ActiveRecord::Base.connection
  end
end

extend IRBHelpers

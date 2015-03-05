require "readline"

module MAL
  extend self

  def read(arg)
    arg
  end

  def eval(arg)
    arg
  end

  def print(arg)
    arg
  end

  def rep(arg)
    print(eval(read(arg)))
  end
end

loop do
  line = Readline.readline("user> ", add_history = true)
  puts MAL.rep(line)
  break unless line
end

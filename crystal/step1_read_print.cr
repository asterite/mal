require "readline"
require "./types"
require "./reader"
require "./printer"

module MAL
  extend self

  def read(arg)
    Reader.read(arg)
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
  break unless line
  puts MAL.rep(line)
end

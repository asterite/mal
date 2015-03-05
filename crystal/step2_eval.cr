require "readline"
require "./types"
require "./reader"
require "./printer"

module MAL
  extend self

  def read(arg)
    Reader.read(arg)
  end

  def eval(arg : List, env)
    new_list = eval_ast arg, env
    first = new_list[0]
    if first.is_a?(Function)
      first.call(new_list[1 .. -1])
    else
      raise "'#{first}' is not a function"
    end
  end

  def eval(arg, env)
    eval_ast arg, env
  end

  def print(arg)
    arg
  end

  def rep(arg)
    print(eval(read(arg), $repl_env))
  end

  def eval_ast(ast : Symbol, env)
    env[ast.value]? || raise("'#{ast}' not found")
  end

  def eval_ast(ast : List, env)
    List.new(ast.elements.map { |elem| eval(elem, env) })
  end

  def eval_ast(ast : Vector, env)
    Vector.new(ast.elements.map { |elem| eval(elem, env) })
  end

  def eval_ast(ast : HashMap, env)
    HashMap.new(ast.elements.map { |elem| eval(elem, env) })
  end

  def eval_ast(ast, env)
    ast
  end

  macro wrap_number_function(op)
    Function.new do |args|
      Number.new((args[0].as_number).value {{op.id}} (args[1].as_number).value)
    end
  end

  $repl_env = {
      "+": wrap_number_function(:+),
      "-": wrap_number_function(:-),
      "*": wrap_number_function(:*),
      "/": wrap_number_function(:/),
    }
end

loop do
  line = Readline.readline("user> ", add_history = true)
  break unless line
  begin
    puts MAL.rep(line)
  rescue ex
    puts ex
  end
end

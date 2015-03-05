require "readline"
require "./types"
require "./reader"
require "./printer"
require "./env"

module MAL
  extend self

  def read(arg)
    Reader.read(arg)
  end

  def eval(list : List, env)
    first, second, third = list

    if first.is_a?(Symbol)
      case first.value
      when "def!"
        key = second.as_symbol.value
        value = eval(third, env)
        env.set key, value
        return value
      when "let*"
        new_env = Env.new(env)
        elems = second.elements
        0.step(by: 2, limit: elems.length - 1) do |i|
          key = elems[i].as_symbol.value
          value = eval(elems[i + 1], new_env)
          new_env.set key, value
        end
        return eval(third, new_env)
      end
    end

    new_list = eval_ast list, env
    first = new_list[0]

    first.as_function.call(new_list[1 .. -1])
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
    env.get(ast.value) || raise("'#{ast}' not found")
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

  $repl_env = Env.new
  {% for name in %w(+ - * /) %}
    $repl_env.set {{name}}, wrap_number_function({{name}})
  {% end %}
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

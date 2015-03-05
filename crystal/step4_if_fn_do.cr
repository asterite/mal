require "readline"
require "./types"
require "./reader"
require "./printer"
require "./env"
require "./core"

module MAL
  extend self

  def read(arg)
    Reader.read(arg)
  end

  def eval(list : List, env)
    first = list[0]

    if first.is_a?(Symbol)
      case first.value
      when "def!"
        key = list[1].as_symbol.value
        value = eval(list[2], env)
        env.set key, value
        return value
      when "let*"
        new_env = Env.new(env)
        elems = list[1].elements
        0.step(by: 2, limit: elems.length - 1) do |i|
          key = elems[i].as_symbol.value
          value = eval(elems[i + 1], new_env)
          new_env.set key, value
        end
        return eval(list[2], new_env)
      when "do"
        return eval_ast(List.new(list[1 .. -1]), env)[-1]
      when "if"
        cond = list[1]
        cond_value = eval(cond, env)
        case cond_value
        when Nil, False
          if if_else = list[3]?
            return eval(if_else, env)
          else
            return Nil::INSTANCE
          end
        else
          return eval(list[2], env)
        end
      when "fn*"
        return Function.new do |args|
          new_env = Env.new(env, list[1].elements, args)
          eval list[2], new_env
        end
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

  $repl_env = Env.new
  $ns.each do |key, value|
    $repl_env.set key, value
  end

  rep "(def! not (fn* (a) (if a false true)))"
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

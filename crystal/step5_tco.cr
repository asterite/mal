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

  def eval(ast, env)
    loop do
      case ast
      when List
        first = ast[0]

        if first.is_a?(Symbol)
          case first.value
          when "def!"
            key = ast[1].as_symbol.value
            value = eval(ast[2], env)
            env.set key, value
            return value
          when "let*"
            let_env = Env.new(env)
            elems = ast[1].elements
            0.step(by: 2, limit: elems.length - 1) do |i|
              key = elems[i].as_symbol.value
              value = eval(elems[i + 1], let_env)
              let_env.set key, value
            end
            env = let_env
            ast = ast[2]
            next
          when "do"
            eval_ast(List.new(ast[1 .. -2]), env)
            ast = ast[-1]
            next
          when "if"
            cond = ast[1]
            cond_value = eval(cond, env)
            case cond_value
            when Nil, False
              ast = ast[3]? || Nil::INSTANCE
            else
              ast = ast[2]
            end
            next
          when "fn*"
            captured_ast = ast
            return MalFunction.new(ast[2], ast[1].elements, env) do |args|
              fun_env = Env.new(env, captured_ast[1].elements, args)
              eval captured_ast[2], fun_env
            end
          end
        end

        new_list = eval_ast ast, env
        first = new_list[0]

        case first
        when MalFunction
          ast = first.ast
          env = Env.new(first.env, first.params, new_list[1 .. -1])
        else
          return first.as_function.call(new_list[1 .. -1])
        end
      else
        return eval_ast ast, env
      end
    end
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
    List.new(ast.elements.map { |elem| eval(elem, env) as Type })
  end

  def eval_ast(ast : Vector, env)
    Vector.new(ast.elements.map { |elem| eval(elem, env) as Type })
  end

  def eval_ast(ast : HashMap, env)
    HashMap.new(ast.elements.map { |elem| eval(elem, env) as Type })
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

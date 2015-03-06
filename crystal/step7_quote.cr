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
          when "quote"
            return ast[1]
          when "quasiquote"
            ast = quasiquote ast[1]
            next
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

  def is_pair(ast)
    case ast
    when List
      !ast.elements.empty?
    when Vector
      !ast.elements.empty?
    else
      false
    end
  end

  def quasiquote(ast)
    unless is_pair(ast)
      return List.new(Symbol.new("quote"), ast)
    end

    elems = ast.elements
    first = elems[0]

    if first.symbol?("unquote")
      return elems[1]
    end

    if is_pair(first)
      sub_elems = first.elements
      if sub_elems[0].symbol?("splice-unquote")
        return List.new(Symbol.new("concat"), sub_elems[1], quasiquote(List.new(elems[1 .. -1])))
      end
    end

    List.new(Symbol.new("cons"), quasiquote(first), quasiquote(List.new(elems[1 .. -1])))
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
  $repl_env.set("eval", Function.new do |args|
    eval(args[0], $repl_env)
  end)

  rep "(def! not (fn* (a) (if a false true)))"
  rep %((def! load-file (fn* (f) (eval (read-string (str "(do " (slurp f) ")"))))))

  filename = ARGV.shift?

  $repl_env.set "*ARGV*", List.new(ARGV.map { |arg| String.new(arg) as Type })

  if filename && File.file?(filename)
    rep %[(load-file "#{filename}")]
    exit
  end

  loop do
    line = Readline.readline("user> ", add_history = true)
    break unless line
    begin
      puts rep(line)
    rescue ex
      puts ex
    end
  end
end


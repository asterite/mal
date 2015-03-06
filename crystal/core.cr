module MAL
  macro wrap_function(op, type)
    Function.new do |args|
      {{type}}.new((args[0].as_number).value {{op.id}} (args[1].as_number).value)
    end
  end

  $ns = {
    "+": wrap_function(:+, Number),
    "-": wrap_function(:-, Number),
    "*": wrap_function(:*, Number),
    "/": wrap_function(:/, Number),
    "<": wrap_function(:<, Bool),
    "<=": wrap_function(:<=, Bool),
    ">": wrap_function(:>, Bool),
    ">=": wrap_function(:>=, Bool),
    "list": Function.new { |args| List.new(args) },
    "list?": Function.new { |args| Bool.new(args[0].is_a?(List)) },
    "empty?": Function.new { |args| Bool.new(args[0].elements.empty?) },
    "count": Function.new { |args| args[0].is_a?(Nil) ? Number.new(0) : Number.new(args[0].elements.length) },
    "=": Function.new { |args| Bool.new(args[0] == args[1]) },

    "pr-str": Function.new do |args|
      String.new(::String.build do |str|
        args.join " ", str, &.to_s(str, true)
      end)
    end,

    "str": Function.new do |args|
      String.new(::String.build do |str|
        args.join "", str, &.to_s(str, false)
      end)
    end,

    "prn": Function.new do |args|
      puts(::String.build do |str|
        args.join " ", str, &.to_s(str, true)
      end)
      Nil::INSTANCE
    end,

    "println": Function.new do |args|
      puts(::String.build do |str|
        args.join " ", str, &.to_s(str, false)
      end)
      Nil::INSTANCE
    end,

    "read-string": Function.new do |args|
      Reader.read(args[0].as_string.value)
    end,

    "slurp": Function.new do |args|
      String.new(File.read(args[0].as_string.value))
    end,

    "cons": Function.new do |args|
      elems = args[1].elements
      new_elems = Array(Type).new(elems.length + 1)
      new_elems << args[0]
      new_elems.concat elems
      List.new(new_elems)
    end,

    "concat": Function.new do |args|
      List.new(args.each_with_object([] of Type) do |arg, elems|
        elems.concat arg.elements
      end)
    end,
  }
end

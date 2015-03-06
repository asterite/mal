module MAL
  abstract class Type
    def as_number
      raise "#{self} is not a Number"
    end

    def as_symbol
      raise "#{self} is not a Symbol"
    end

    def as_string
      raise "#{self} is not a String"
    end

    def as_function
      raise "#{self} is not a Function"
    end

    def as_list
      raise "#{self} is not a List"
    end

    def elements
      raise "#{self} is not a List or Vector"
    end

    def symbol?(name)
      false
    end
  end

  class Nil < Type
    INSTANCE = new

    def_equals
  end

  class True < Type
    INSTANCE = new

    def_equals
  end

  class False < Type
    INSTANCE = new

    def_equals
  end

  module Bool
    def self.new(value)
      value ? True::INSTANCE : False::INSTANCE
    end
  end

  class Number < Type
    getter value

    def initialize(@value)
    end

    def as_number
      self
    end

    def_equals value
  end

  class String < Type
    getter value

    def initialize(@value)
    end

    def as_string
      self
    end

    def_equals value
  end

  class Keyword < Type
    getter value

    def initialize(@value)
    end

    def_equals value
  end

  class List < Type
    getter elements

    def initialize(@elements : Array(Type))
    end

    def self.new(first : Type, *rest)
      elements = Array(Type).new(rest.length + 1)
      elements << first
      elements.concat rest
      new elements
    end

    def [](index)
      @elements[index]
    end

    def []?(index)
      @elements[index]?
    end

    def as_list
      self
    end

    def_equals elements

    def ==(other : Vector)
      elements == other.elements
    end
  end

  class Vector < Type
    getter elements

    def initialize(@elements)
    end

    def_equals elements

    def ==(other : List)
      elements == other.elements
    end
  end

  class HashMap < Type
    getter elements

    def initialize(@elements)
    end

    def_equals elements
  end

  class Symbol < Type
    getter value

    def initialize(@value)
    end

    def symbol?(name)
      value == name
    end

    def as_symbol
      self
    end

    def_equals value
  end

  class Function < Type
    def initialize(&@function : Array(Type) -> Type)
    end

    def call(args)
      @function.call(args)
    end

    def as_function
      self
    end
  end

  class MalFunction < Type
    getter ast
    getter params
    getter env

    def initialize(@ast, @params, @env, &function : Array(Type) -> Type)
      @function = Function.new(&function)
    end
  end
end

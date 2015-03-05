module MAL
  abstract class Type
    def as_number
      raise "#{self} is not a Number"
    end
  end

  class Nil < Type
    INSTANCE = new
  end

  class True < Type
    INSTANCE = new
  end

  class False < Type
    INSTANCE = new
  end

  class Number < Type
    getter value

    def initialize(@value)
    end

    def as_number
      self
    end
  end

  class String < Type
    getter value

    def initialize(@value)
    end
  end

  class Keyword < Type
    getter value

    def initialize(@value)
    end
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
  end

  class Vector < Type
    getter elements

    def initialize(@elements)
    end
  end

  class HashMap < Type
    getter elements

    def initialize(@elements)
    end
  end

  class Symbol < Type
    getter value

    def initialize(@value)
    end
  end

  class Function < Type
    def self.new(&function : Array(Type) -> Type)
      new function
    end

    def initialize(@function)
    end

    def call(args)
      @function.call(args)
    end
  end
end

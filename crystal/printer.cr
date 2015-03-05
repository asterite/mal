module MAL
  class Type
    def inspect(io)
      to_s(io)
    end
  end

  class Nil < Type
    def to_s(io)
      io << "nil"
    end
  end

  class True < Type
    def to_s(io)
      io << "true"
    end
  end

  class False < Type
    def to_s(io)
      io << "false"
    end
  end

  class Number < Type
    def to_s(io)
      io << value
    end
  end

  class String < Type
    def to_s(io)
      io << '"'
      io << value.gsub('"', "\\\"")
      io << '"'
    end
  end

  class Keyword < Type
    def to_s(io)
      io << ':'
      io << value
    end
  end

  class List < Type
    def to_s(io)
      io << '('
      elements.join(' ', io)
      io << ')'
    end
  end

  class Vector < Type
    def to_s(io)
      io << '['
      elements.join(' ', io)
      io << ']'
    end
  end

  class HashMap < Type
    def to_s(io)
      io << '{'
      elements.join(' ', io)
      io << '}'
    end
  end

  class Symbol < Type
    def to_s(io)
      io << value
    end
  end

  class Function < Type
    def to_s(io)
      io << "->"
    end
  end
end

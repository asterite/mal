module MAL
  class Type
    def inspect(io)
      to_s(io)
    end

    def to_s(io : IO)
      to_s io, true
    end

    def to_s(readably : ::Bool)
      ::String.build do |io|
        to_s io, readably
      end
    end
  end

  class Nil < Type
    def to_s(io : IO, readably : ::Bool)
      io << "nil"
    end
  end

  class True < Type
    def to_s(io : IO, readably : ::Bool)
      io << "true"
    end
  end

  class False < Type
    def to_s(io : IO, readably : ::Bool)
      io << "false"
    end
  end

  class Number < Type
    def to_s(io : IO, readably : ::Bool)
      io << value
    end
  end

  class String < Type
    def to_s(io : IO, readably : ::Bool)
      if readably
        value.inspect(io)
      else
        value.to_s(io)
      end
    end
  end

  class Keyword < Type
    def to_s(io : IO, readably : ::Bool)
      io << ':'
      io << value
    end
  end

  class List < Type
    def to_s(io : IO, readably : ::Bool)
      io << '('
      elements.join ' ', io, &.to_s(io, readably)
      io << ')'
    end
  end

  class Vector < Type
    def to_s(io : IO, readably : ::Bool)
      io << '['
      elements.join ' ', io, &.to_s(io, readably)
      io << ']'
    end
  end

  class HashMap < Type
    def to_s(io : IO, readably : ::Bool)
      io << '{'
      elements.join ' ', io, &.to_s(io, readably)
      io << '}'
    end
  end

  class Symbol < Type
    def to_s(io : IO, readably : ::Bool)
      io << value
    end
  end

  class Function < Type
    def to_s(io : IO, readably : ::Bool)
      io << "#"
    end
  end

  class MalFunction < Type
    def to_s(io : IO, readably : ::Bool)
      io << "#"
    end
  end
end

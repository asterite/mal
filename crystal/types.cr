module MAL
  abstract class Type
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
    def initialize(@value)
    end
  end

  class String < Type
    def initialize(@value)
    end
  end

  class Keyword < Type
    def initialize(@value)
    end
  end

  class List < Type
    def initialize(@elements)
    end
  end

  class Vector < Type
    def initialize(@elements)
    end
  end

  class HashMap < Type
    def initialize(@elements)
    end
  end

  class Symbol < Type
    def initialize(@value)
    end
  end
end

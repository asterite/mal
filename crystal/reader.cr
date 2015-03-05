class MAL::Reader
  TOKENS_REGEX = %r([\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*))
  INT_REGEX = %r(^-?[0-9]+$)

  def self.read(string)
    reader = new(tokenize(string))
    reader.read_form
  end

  def initialize(@tokens)
    @position = 0
  end

  protected def self.tokenize(string)
    tokens = [] of ::String
    string.scan(TOKENS_REGEX) do |match|
      capture = match[1]
      tokens << capture unless capture.empty? || capture.starts_with?(';')
    end
    tokens
  end

  protected def next
    @position += 1
    @tokens[@position - 1]
  end

  protected def peek
    @tokens[@position]?
  end

  protected def read_form
    token = self.peek

    case token
    when /$;/
      Nil::INSTANCE
    when "'"
      self.next
      List.new Symbol.new("quote"), read_form
    when "`"
      self.next
      List.new Symbol.new("quasiquote"), read_form
    when "~"
      self.next
      List.new Symbol.new("unquote"), read_form
    when "~@"
      self.next
      List.new Symbol.new("splice-unquote"), read_form
    when "^"
      self.next
      meta = read_form
      List.new Symbol.new("with-meta"), read_form, meta
    when "@"
      self.next
      List.new Symbol.new("deref"), read_form
    when "("
      read_list
    when ")"
      raise "unexpected ')'"
    when "["
      read_vector
    when "]"
      raise "unexpected ']'"
    when "{"
      read_hash_map
    when "}"
      raise "unexpected '}'"
    else
      read_atom
    end
  end

  protected def read_list
    List.new read_seq("(", ")")
  end

  protected def read_vector
    Vector.new read_seq("[", "]")
  end

  protected def read_hash_map
    HashMap.new read_seq("{", "}")
  end

  protected def read_seq(from, to)
    elements = [] of Type

    token = self.next
    raise "expected '#{from}'" unless token == from

    token = self.peek
    until token == to
      raise "expected '#{to}', got EOF" unless token
      elements << read_form
      token = self.peek
    end
    self.next

    elements
  end

  protected def read_atom
    token = self.next

    case token
    when INT_REGEX
      Number.new(token.to_i)
    when .starts_with?('"')
      String.new(token[1 ... -1].gsub(/\\\"/, "\""))
    when .starts_with?(':')
      Keyword.new(token[1 .. -1])
    when "nil"
      Nil::INSTANCE
    when "true"
      True::INSTANCE
    when "false"
      False::INSTANCE
    else
      Symbol.new(token)
    end
  end
end

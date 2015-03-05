class MAL::Env
  protected getter data

  def initialize(@outer = nil, binds = nil, exprs = nil)
    @data = {} of ::String => Type

    if binds && exprs
      binds.each_with_index do |bind, index|
        name = bind.as_symbol.value
        if name == "&"
          @data[binds[index + 1].as_symbol.value] = List.new exprs[index .. -1]
          break
        else
          expr = exprs[index]
          @data[name] = expr
        end
      end
    end
  end

  def set(key, value)
    @data[key] = value
  end

  def find(key)
    if @data.has_key?(key)
      self
    else
      @outer.try &.find(key)
    end
  end

  def get(key)
    find(key).try &.data[key]
  end
end

class MAL::Env
  protected getter data

  def initialize(@outer = nil)
    @data = {} of ::String => Type
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

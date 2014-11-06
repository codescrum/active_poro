# this is just a class that includes convenience methods for testing
# such as a giving it a name so that is easy to inspect
BaseTestClass = Struct.new(:name) do

  def to_s
    name
  end

  def inspect
    "\"#{self}\""
  end
end

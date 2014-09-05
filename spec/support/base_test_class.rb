# this is just a class that includes convenience methods for testing
# such as a giving it a name so that is easy to inspect
class BaseTestClass
  attr_accessor :name

  def initialize(name)
    self.name = name
  end

  def to_s
    name
  end

  def inspect
    "\"#{to_s}\""
  end
end

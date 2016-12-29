class ApplicationPolicy
  def initialize(*_)
  end

  def self.allowed?(*_)
    new(*_).allowed?
  end
end

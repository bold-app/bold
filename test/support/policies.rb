class YesPolicy < ApplicationPolicy
  def allowed?
    true
  end
end

class NoPolicy < ApplicationPolicy
  def allowed?
    false
  end
end

class PlanningPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    true
  end

  def skeleton?
    user.is_owner?
  end

  def users?
    user.is_owner?
  end

  def skeleton?
    user.is_owner?
  end

end

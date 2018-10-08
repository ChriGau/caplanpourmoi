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
    user.is_owner
  end

  def users?
    user.is_owner
  end

  def conflicts?
    true
  end

  def events?
    true
  end

  def create?
    true
  end

  def update?
    user.is_owner
  end

  def resultevents?
    true
  end

  def use_template?
    user.is_owner
  end

end

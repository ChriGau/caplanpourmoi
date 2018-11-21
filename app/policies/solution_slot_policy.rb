class SolutionSlotPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def edit?
    user.is_owner
  end

  def update?
    edit?
  end
end

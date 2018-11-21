class SolutionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def show?
    true
  end

  def change_effectivity?
    user.is_owner
  end
end

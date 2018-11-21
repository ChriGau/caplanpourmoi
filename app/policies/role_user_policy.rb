class RoleUserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    user.is_owner?
  end

  def destroy?
    user.is_owner?
  end
end

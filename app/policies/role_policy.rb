class RolePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def new?
    create?
  end

  def create?
    user.is_owner
  end

  def edit?
    update?
  end

  def update?
    user.is_owner
  end

  def destroy?
    user.is_owner
  end
end

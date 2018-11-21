class ConstraintPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    user.is_owner || user = record.user
  end

  def update?
    user.is_owner || user = record.user
  end

  def destroy?
    user.is_owner || user = record.user
  end
end
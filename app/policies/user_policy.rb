class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.active.where(is_owner: false)
    end
  end

  def index?
    user.is_owner
  end

  def show?
    record == user || user.is_owner
  end

  def new?
    user.is_owner
  end

  def update?
    user.is_owner? || user == record
  end

  def user_invite?
    user.is_owner
  end

  def personnal_constraints?
    user.is_owner? || user == record
  end

  def personnal_constraints_and_working_hours?
    user.is_owner? || user == record
  end

  def permitted_attributes
    if user.is_owner?
      [:profile_picture, :first_name, :last_name, :email, :is_owner, :working_hours, role_ids: []]
    elsif record == user
      [:profile_picture, :email, :first_name, :last_name]
    else
      false
    end
  end

end

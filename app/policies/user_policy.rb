class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    true
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

  def permitted_attributes
    if user.is_owner?
      [:profile_picture, :first_name, :last_name, :email, :working_hours, role_ids: []]
    elsif record == user
      [:profile_picture]
    else
      false
    end
  end

end

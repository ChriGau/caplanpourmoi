class ComputeSolutionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    user.is_owner
  end

  def show_calculation_details?
    user.is_owner
  end
end

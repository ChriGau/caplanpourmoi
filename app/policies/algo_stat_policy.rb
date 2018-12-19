class AlgoStatPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def show_statistics_algo?
    user.is_owner?
  end

  def reload_statistics?
    user.is_owner?
  end

end

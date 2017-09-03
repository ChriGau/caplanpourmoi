module ApplicationHelper
  def fetch_roles
    Role.all.order(:name)
  end

  def get_step_status(url_prop)
    case url_prop
    when "skeleton"
      @set_status1 = "active"
      @set_status2 = "disabled"
      @set_status3 = "disabled"
    when "users"
      @set_status1 = "completed"
      @set_status2 = "active"
      @set_status3 = "disabled"
    else
      @set_status1 = "completed"
      @set_status2 = "completed"
      @set_status3 = "active"
    end
  end

end

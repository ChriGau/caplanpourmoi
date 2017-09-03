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
      @triangle_position = "calc(16% - 70px)"
    when "users"
      @set_status1 = "completed"
      @set_status2 = "active"
      @set_status3 = "disabled"
      @triangle_position = "calc(50% - 70px)"
    else
      @set_status1 = "completed"
      @set_status2 = "completed"
      @set_status3 = "active"
      @triangle_position = "calc(84% - 70px)"
    end
  end

end

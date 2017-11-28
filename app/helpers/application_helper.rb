module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def resource_class
    User
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def fetch_roles
    Role.all.order(:name)
  end

  def set_step_status
    case action_name
    when "skeleton"
      @set_status1 = "active"
      @set_status2 = "disabled"
      @set_status3 = "disabled"
      @triangle_position = "calc(16% - 70px)"
      @button_link = link_to "Etape suivante", planning_users_path(@planning), class: "button"
    when "users"
      @set_status1 = "completed"
      @set_status2 = "active"
      @set_status3 = "disabled"
      @triangle_position = "calc(50% - 70px)"
      @button_link = link_to "Calcul du planning", planning_conflicts_path(@planning), class: "button", id: "user-submit-btn"
    else
      @set_status1 = "completed"
      @set_status2 = "completed"
      @set_status3 = "active"
      @triangle_position = "calc(84% - 70px)"
      @button_link = link_to "Retour au dashboard", plannings_path(@planning), class: "button"

    end
  end

  def fetch_user_solution
    User.where(first_name: "jean")
  end

end

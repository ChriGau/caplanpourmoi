module ApplicationHelper
  def fetch_roles
    Role.all.order(:name)
  end

  def set_step_status
    case action_name
    when "skeleton"
      @set_status1 = "active"
      @set_status2 = "disabled"
      @set_status3 = "disabled"
      @triangle_position = "calc(25% - 228px)"
      @button_link = link_to "Etape suivante", planning_users_path(@planning), class: "button"
    when "users"
      @set_status1 = "completed"
      @set_status2 = "active"
      @set_status3 = "disabled"
      @triangle_position = "calc(50% - 225px)"
      @button_link = link_to "Calcul du planing", planning_conflicts_path(@planning), class: "button", id: "user-submit-btn"
    else
      @set_status1 = "completed"
      @set_status2 = "completed"
      @set_status3 = "active"
      @triangle_position = "calc(75% - 221px)"
      @button_link = link_to "Retour au dashboard", plannings_path(@planning), class: "button"

    end
  end

  def fetch_user_solution
    User.where(first_name: "jean")
  end
end

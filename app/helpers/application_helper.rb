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
    Role.all.order(:name).each {|role| role.name.capitalize! }
  end

  # rubocop:disable AbcSize, LineLength, MethodLength
  def set_step_status
    case action_name
    when 'skeleton'
      @set_status1 = 'active'
      @set_status2 = 'disabled'
      @set_status3 = 'disabled'
      @set_status4 = 'disabled'
      @button_link = link_to 'Etape suivante', planning_users_path(@planning), class: 'button'
    when 'users'
      @set_status1 = 'completed'
      @set_status2 = 'active'
      @set_status3 = 'disabled'
      @set_status4 = 'disabled'
      @button_link = content_tag "a", 'Calcul', class: 'button', id: 'user-submit-btn'
    when 'index'
      @set_status1 = 'completed'
      @set_status2 = 'completed'
      @set_status3 = 'active'
      @set_status4 = 'disabled'
      if @solution
        @button_link = link_to 'Planning', planning_conflicts_path(@planning, solution_id: @solution), class: 'button'
      else
        @button_link = link_to 'Planning', planning_conflicts_path(@planning), class: 'button'
      end
    else
      @set_status1 = 'completed'
      @set_status2 = 'completed'
      @set_status3 = 'completed'
      @set_status4 = 'active'
      @button_link = link_to 'Dashboard', plannings_path(@planning), class: 'button'

    end
  end
  # rubocop:enable AbcSize, LineLength, MethodLength

  def fetch_user_solution
    User.where(first_name: 'jean')
  end

end

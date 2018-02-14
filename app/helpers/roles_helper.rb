module RolesHelper
  def background_text_color(slot_template)
    case slot_template.role.role_color
    when 'black','#C6B849','#8D816F','#89043D'
      'color: #F2F2F2'
    end
  end

  def background_text_color_role(role)
    case role.role_color
    when 'black','#C6B849','#8D816F','#89043D'
      'color: #F2F2F2'
    end
  end

  def role_color(role_name)
    Role.find_by(name: role_name).role_color
  end

  def role_text_color(role_name)
    background_text_color_role(Role.find_by(name: role_name))

  end
end

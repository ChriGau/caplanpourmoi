module RolesHelper
  def background_text_color(slot_template)
    case slot_template.role.color.hexadecimal_code
    when 'black','#C6B849','#8D816F','#89043D'
      'color: #F2F2F2'
    end
  end

  def background_text_color_role(role)
    case role.role.color.hexadecimal_code
    when 'black','#C6B849','#8D816F','#89043D'
      'color: #F2F2F2'
    end
  end

  def role_color(role_name)
    Role.find_by(name: role_name).color.hexadecimal_code
  end

  def role_text_color(role_name)
    background_text_color_role(Role.find_by(name: role_name))

  end
end

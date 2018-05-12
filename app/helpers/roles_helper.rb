module RolesHelper
  def background_text_color(slot_template)
    case Color.find_by(id: slot_template.role.color_id).hexadecimal_code
    when 'black','#C6B849','#8D816F','#89043D'
      'color: #F2F2F2'
    end
  end

  def background_text_color_role(role_id)
    case Color.find(Role.find(role_id).color_id).hexadecimal_code
    when 'black','#C6B849','#8D816F','#89043D'
      'color: #F2F2F2'
    end
  end

  def background_color_of_role(role_id)
    # in computed solutions model, roles are stored as symbols
    Color.find(Role.find(role_id).color_id).hexadecimal_code
  end

  def role_text_color(role_id)
    background_text_color_role(Role.find(role_id))
  end
end

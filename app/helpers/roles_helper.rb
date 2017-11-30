module RolesHelper
  def background_text_color(slot_template)
    case slot_template.role.role_color
    when 'black', '#89043D'
      'color: #F2F2F2'
    end
  end

  def background_text_color_role(role)
    case role.role_color
    when 'black', '#89043D'
      'color: #F2F2F2'
    end
  end
end

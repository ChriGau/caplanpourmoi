module RolesHelper
  def background_text_color(slot_template)
    case slot_template.role.role_color
    when "black", "#89043D"
      "color: white"
    else
      "color: black"
    end
  end
end

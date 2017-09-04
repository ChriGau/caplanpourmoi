module UserHelper
  def avatar_with_border_color(user)
    color = user.roles[0].role_color if user.roles.any?
    color ||= "black"

    options = {
      class: "user-avatar-index",
      style: "border: solid 6px #{color}",
    }

    if user.profile_picture?
      cl_image_tag user.profile_picture.path, options
    else
      image_tag "https://placehold.it/30x30", options
    end
  end
end

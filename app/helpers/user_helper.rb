module UserHelper
  def avatar_with_border_color(user)
    color = user.roles[0].color.hexadecimal_code if user.roles.any?
    color ||= 'black'

    options = { class: 'user-avatar-index', style: "border: solid 6px #{color}" }

    if user.profile_picture?
      cl_image_tag user.profile_picture.path, options
    else
      image_tag 'https://placehold.it/30x30', options
    end
  end

  def profile_picture(user)
    if user.profile_picture?
      cl_image_tag user.profile_picture.path, class: 'avatar'
    else
      image_tag 'https://placehold.it/30x30', class: 'avatar'
    end
  end

  def invitation_status(user)
    if !user.invitation_accepted_at.nil?
      "green"
    elsif !user.invitation_sent_at.nil?
      "orange"
    end
  end
end

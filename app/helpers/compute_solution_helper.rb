module ComputeSolutionHelper

  def s_in_h(seconds)
    unless seconds.nil?
      [seconds / 3600, seconds / 60 % 60].map { |t| t.to_s.rjust(2,'0') }.join('h')
    end
  end

  def update_key_name_of_a_hash(associated_instance, hash_to_update, old_key, new_key)
    # replace old key by new key
    hash_to_update[new_name.to_s.to_sym] = p_nb_hours_roles.delete role_name.to_sym
    associated_instance.save!
  end

end

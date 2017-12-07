# creates slotgroups from a collection of slots
# calculates the slotgroup's caracteristics
# determine each slot's simulation_status

# rubocop:disable LineLength, MethodLength, ClassLength

class CreateSlotgroupsService
  def initialize(slots_array, planning, calcul_solution_v1_instance)
    @slots_array =  slots_array # [ {} , {} ]
    @slots_array =  slots_array # [ {} , {} ]
    @planning = planning
    @users = @planning.users
    @calcul = calcul_solution_v1_instance
  end

  def perform
    slotgroups_array = create_slotgroups(@slots_array) # step 1.1
    calculate_caracteristics_slotgroups(slotgroups_array) # step 1.2. & 2.
    determine_slots_simulation_status(slotgroups_array) # step 2.
    determine_slotgroups_simulation_status(slotgroups_array) # step 2.
    save_calcul_items(slotgroups_array, @slots_array, @calcul)
    determine_overlapping_slotgroups(slotgroups_array) # step 3.1.
    determine_overlapping_users(slotgroups_array) # step 3.2.
    fix_overlaps(slotgroups_array, @slots_array) # step 3.3
    determine_slots_simulation_status(slotgroups_array) # step 3.3
    determine_slotgroups_simulation_status(slotgroups_array) # step 3.3
    { slotgroups_array: slotgroups_array, slots_array: @slots_array }
  end

  def create_slotgroups(slots_array)
    slotgroups_array = []
    cpt_slotgroup = 0
    slots_array.each do |slot_hash|
      next unless slot_hash[:slotgroup_id].nil?
      cpt_slotgroup += 1
      slotgroup = initialize_slotgroup_hash(cpt_slotgroup, slot_hash[:slot_instance])
      slotgroups_array << slotgroup
      assign_slotgroup_to_slots(slot_hash[:slot_instance].similar_slots, slotgroup[:slotgroup_id])
    end
    slotgroups_array
  end

  def initialize_slotgroup_hash(cpt_slotgroup, slot_instance)
    { slotgroup_id: cpt_slotgroup,
      start_at: slot_instance[:start_at],
      end_at: slot_instance[:end_at],
      role_id: slot_instance[:role_id],
      role_name: Role.find(slot_instance[:role_id]).name,
      nb_required: nil,
      nb_available: nil,
      list_available_users: nil,
      simulation_status: nil,
      slots_to_simulate: nil,
      overlaps: nil,
      combinations_of_available_users: nil,
      nb_combinations_available_users: nil,
      priority: rand(5), # faked for now
      ranking_algo: nil,
      calculation_interval: nil,
      users_solution: nil }
  end

  def assign_slotgroup_to_slots(similar_slots, slotgroup_id)
    similar_slots.each do |slot|
      h = @slots_array.find { |x| x[:slot_instance] == slot }
      h[:slotgroup_id] = slotgroup_id unless h.nil?
    end
  end

  def calculate_caracteristics_slotgroups(slotgroups_array)
    slotgroups_array.each do |slotgroup|
      slotgroup[:nb_required] = determine_slotgroup_nb_required(slotgroup[:slotgroup_id])
      slotgroup[:nb_available] = determine_slotgroup_availability(@users, slotgroup[:start_at], slotgroup[:end_at], slotgroup[:role_id])[:nb]
      slotgroup[:list_available_users] = determine_slotgroup_availability(@users, slotgroup[:start_at], slotgroup[:end_at], slotgroup[:role_id])[:list]
    end
  end

  def determine_slotgroup_nb_required(slotgroup_id)
    @slots_array.select { |x| x[:slotgroup_id] == slotgroup_id }.count
  end

  def determine_slotgroup_availability(user_instances, start_at, end_at, role_id)
    # sets nb available users + lists them
    nb_available_users = 0
    array_available_users = []
    user_instances.each do |user|
      if user.skilled_and_available?(start_at, end_at, role_id)
        nb_available_users += 1
        array_available_users << user
      end
    end
    { nb: nb_available_users, list: array_available_users }
  end

  def determine_slots_simulation_status(slotgroups_array)
    reset_slots_status_to_false
    slotgroups_array.each do |slotgroup|
      unless slotgroup[:nb_available] == 0
        if slotgroup[:nb_available] >= slotgroup[:nb_required]
          put_slots_simulation_status_to_x(get_similar_slots(slotgroup), true)
        else
          put_slots_simulation_status_to_x(get_similar_slots(slotgroup).first(slotgroup[:nb_available]), true)
        end
      end
    end
  end

  def reset_slots_status_to_false
    @slots_array.each do |x|
      x[:simulation_status] = false
    end
  end

  def get_similar_slots(slotgroup)
    # => [ { } , { } ]
    @slots_array.select { |x| x[:slotgroup_id] == slotgroup[:slotgroup_id] &&
      x[:planning_id] == slotgroup[:planning_id] }
  end

  def put_slots_simulation_status_to_x(slots_hashes, true_or_false)
    slots_hashes.each do |slot_hash|
      @slots_array.select { |x| x[:slot_instance] == slot_hash[:slot_instance] }.each do |slot_hash|
        slot_hash[:simulation_status] = true_or_false
      end
    end
  end

  def determine_slotgroup_simulation_status(slotgroup)

    slotgroup[:simulation_status] = true if nb_slots_to_simulate(slotgroup[:slotgroup_id]).positive?
  end

  def determine_slotgroups_simulation_status(slotgroups)
    determine_slotgroup_simulation_status if slotgroups
    else
    slotgroups.each do |slotgroup|
      determine_slotgroup_simulation_status(slotgroup)
    end
  end

  def nb_slots_to_simulate(slotgroup_id)
    @slots_array.find { |x| x[:slotgroup_id] == slotgroup_id && x[:simulation_status] = true }.count
  end

  # rubocop:enable AbcSize, LineLength

  def save_calcul_items(slotgroups, slots, calcul_solution_v1_instance)
    calcul_solution_v1_instance.slotgroups_array = slotgroups
    calcul_solution_v1_instance.slots_array = slots
    calcul_solution_v1_instance.save
  end

  def determine_overlapping_slotgroups(slotgroups_array)
    slotgroups_array.each do |slotgroup_hash_one|
      l = slotgroups_array.select { |x| slotgroups_overlap?(slotgroup_hash_one, x) &&
        slotgroup_hash_one[:role_id] == x[:role_id] &&
        slotgroup_hash_one[:slotgroup_id] != x[:slotgroup_id] }
        slotgroup_hash_one[:overlaps] = l.map{ |y| { slotgroup_id: y[:slotgroup_id], users: []} }.uniq
    end
  end

  def slotgroups_overlap?(slotgroup_hash_one, slotgroup_hash_two)
    # overlap if (start1 - end2) * (start1 - end2) > 0
    ((slotgroup_hash_one[:start_at] - slotgroup_hash_two[:end_at]) *
    (slotgroup_hash_two[:start_at] - slotgroup_hash_one[:end_at])).positive?
  end

  def determine_overlapping_users(slotgroups_array)
    slotgroups_array.each do |slotgroup_hash|
      next if slotgroup_hash[:nb_required] != slotgroup_hash[:nb_available]
      list_overlapping_users = []
      slotgroup_hash[:overlaps].each do |overlapping_slotgroups_array|
        @overlapping_slotgroup_id = overlapping_slotgroups_array[:slotgroup_id]
        s = find_slotgroup_by_id(slotgroups_array, @overlapping_slotgroup_id)
        next if s[:nb_required] != s[:nb_available] || s[:role_id] != slotgroup_hash[:role_id]
        intersect = s[:list_available_users] & slotgroup_hash[:list_available_users]
        unless intersect.empty? || (not intersect.count.positive?)
          overlapping_users_array = find_overlapping_users_array(slotgroup_hash, @overlapping_slotgroup_id)
          overlapping_users_array << intersect.flatten
          overlapping_users_array.flatten!
        end
      end
    end
  end

  def fix_overlaps(slotgroups_array, slots_array)
    # TODO - define priorities per slotgroup (faked)
    slotgroups_array.sort_by!{ |x| x[:priority] }
    list_changes_made = []
    slotgroups_array.each do |slotgroup_hash|
      slotgroup_hash[:overlaps].each do |slotgroup_overlaps_hash|
        next if slotgroup_overlaps_hash.nil?
        slotgroup_overlaps_hash[:users].each do |overlapping_user|
          # user gets unavailable for overlapping slotgroups
          overlapped_slotgroup = find_slotgroup_by_id(slotgroups_array, slotgroup_overlaps_hash[:slotgroup_id])
          unless list_changes_made.include?([overlapped_slotgroup[:slotgroup_id], overlapping_user])
            make_user_unavailable(@slots_array, slotgroups_array, overlapped_slotgroup, slotgroup_hash[:slotgroup_id], overlapping_user)
          end
          list_changes_made << [slotgroup_hash[:slotgroup_id], overlapping_user]
        end
      end
    end
  end

  private

  def find_slotgroup_by_id(slotgroups_array, slotgroup_id) # returns slotgroup hash
    slotgroups_array.find { |x| x[:slotgroup_id] == slotgroup_id }
  end

  def find_overlapping_users_array(slotgroups_hash, overlapping_slotgroup_id)
    slotgroups_hash[:overlaps].find { |x| x[:slotgroup_id] == overlapping_slotgroup_id }[:users]
  end

  def make_user_unavailable(slots_array, slotgroups_array, overlapped_slotgroup, overlapping_slotgroup, overlapping_user)
    # make unavailable in overlapped slotgroup
    if overlapped_slotgroup[:list_available_users].include?(overlapping_user)
      overlapped_slotgroup[:list_available_users].delete(overlapping_user)
      overlapped_slotgroup[:nb_available] -= 1 if overlapped_slotgroup[:nb_available] != 0
    end
  end
end

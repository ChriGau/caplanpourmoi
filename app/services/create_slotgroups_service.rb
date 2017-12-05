# creates slotgroups from a collection of slots
# calculates the slotgroup's caracteristics
# determine each slot's simulation_status

# rubocop:disable LineLength, MethodLength, ClassLength
class CreateSlotgroupsService
  def initialize(slots_array, planning, calcul_solution_v1_instance)
    @slots_array =  slots_array # [ {} , {} ]
    @slots_array =  slots_array # [ {} , {} ]
    @planning = planning
    @users = @planning.users # array of instances of users
    @calcul = calcul_solution_v1_instance
  end

  def perform
    slotgroups_array = create_slotgroups(@slots_array)
    calculate_caracteristics_slotgroups(slotgroups_array)
    determine_slots_simulation_status(slotgroups_array)
    determine_slotgroups_simulation_status(slotgroups_array)
    save_calcul_items(slotgroups_array, @slots_array, @calcul)
    determine_overlapping_slotgroups(slotgroups_array, @slots_array, @calcul)
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
      overlapping_slotgroups: nil,
      overlapping_users: nil,
      combinations_of_available_users: nil,
      nb_combinations_available_users: nil,
      priority: nil,
      ranking_algo: nil,
      calculation_interval: nil }
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
    slotgroups_array.each do |slotgroup|
      if slotgroup[:nb_available] >= slotgroup[:nb_required]
        put_slots_simulation_status_to_true(get_similar_slots(slotgroup[:slotgroup_id]))
      else
        put_slots_simulation_status_to_true(get_similar_slots(slotgroup[:slotgroup_id]).first(slotgroup[:nb_available]))
        # note: slot.simulation_status is set to false by default
      end
    end
  end

  def get_similar_slots(slotgroup_id)
    # => [ { } , { } ]
    @slots_array.select { |x| x[:slotgroup_id] == slotgroup_id }
  end

  def put_slots_simulation_status_to_true(slots_hashes)
    slots_hashes.each do |slot_hash|
      @slots_array.find { |x| x[:slot_instance] == slot_hash[:slot_instance] }[:simulation_status] = true
    end
  end

  def determine_slotgroups_simulation_status(slotgroups)
    slotgroups.each do |slotgroup|
      slotgroup[:simulation_status] = true if nb_slots_to_simulate(slotgroup[:slotgroup_id]).positive?
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

  def determine_overlapping_slotgroups(slotgroups_array, slotgroup, calcul)
    slotgroups_array.each do |slotgroup_hash_1|
      list_overlapping_slotgroups = []
      slotgroups_array.each do |slotgroup_hash_2|
        if slotgroup_hash_1[:slotgroup_id] != slotgroup_hash_2[:slotgroup_id] &&
          slotgroup_hash_2[:start_at] < slotgroup_hash_1[:end_at] &&
          slotgroup_hash_2[:end_at] > slotgroup_hash_1[:start_at]
          list_overlapping_slotgroups << slotgroup_hash_2[:slotgroup_id]
        end
        slotgroup_hash_1[:overlapping_slotgroups] = list_overlapping_slotgroups
        # ('start_at <= ? and end_at >= ?', slotgroup_hash[:start_at], slotgroup_hash[:start_at])?
      end
    end
  end
end

# creates slotgroups from a collection of slots
# calculates the slotgroup's caracteristics
# determine each slot's simulation_status
class CreateSlotgroupsService

  def initialize(initialized_slots_array, planning)
    @slots_array = initialized_slots_array
    users = planning.users # array of instances of users
  end

  def perform
    slotgroups_array = []
    slotgroups_array = create_slotgroups(@slots_array)
    calculate_caracteristics_slotgroups(slotgroups_array)
    # set_slot_simulation_status(@slots)
    # set_slotgroup_simulation_status(@slotgroups)
  end

  def create_slotgroups(initialized_slots_array)
    slotgroups_array = []
    cpt_slotgroup = 0
    @slots_array.each do |slot_hash|
      if slot_hash[:slotgroup_id].nil?
        cpt_slotgroup += 1
        slotgroup = initialize_slotgroup_hash(cpt_slotgroup, slot_hash[:slot_instance])
        slotgroups_array << slotgroup
        assign_slotgroup_to_slots(slot_hash[:slot_instance].similar_slots, slotgroup[:slotgroup_id])
      end
    end
    return slotgroups_array
  end

  def initialize_slotgroup_hash(cpt_slotgroup, slot_instance)
    h = { slotgroup_id: cpt_slotgroup,
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

  def calculate_caracteristics_slotgroups(slotgroups_array)
    slotgroups_array.each do |slotgroup|
      slotgroup[:nb_required] = set_slotgroup_nb_required(slotgroup[:slotgroup_id])
      slotgroup[:nb_available] = set_slotgroup_nb_available(slotgroup[:slotgroup_id], )
    end
  end

  def assign_slotgroup_to_slots(similar_slots, slotgroup_id)
    similar_slots.each do |slot|
      h = @slots_array.find {|x| x[:slot_instance] == slot }
      if h != nil
        h[:slotgroup_id] = slotgroup_id
      end
    end
  end

  def set_slotgroup_nb_required(slotgroup_id)
    @slots_array.find {|x| x[:slotgroup_id] == slotgroup_id }.count
  end

  def set_slotgroup_nb_available(user_instances, start_at, end_at, role_id)
    cpt = 0
    user_instances.each do |user|
      cpt += 1 if user.is_skilled_and_available?(start_at, end_at, role_id)?
    end
  end

  # def set_slot_simulation_status(slots)
  #   slotgroups = get_array_of_slotgroups(slots)
  #   slotgroups.each do |slotgroup|
  #     if slotgroup.nb_available >= slotgroup.nb_required
  #       set_slot_simulation_status_to_true(slotgroup.slots)
  #     else
  #       set_slot_simulation_status_to_true(slotgroup.slots.first(slotgroup.nb_available)
  #       # note: slot.simulation_status is set to false by default
  #     end
  #   end
  #   # TODO? add check if all slots have a slotgroup_id != nil?
  # end

  def get_array_of_slotgroups(slots)
    array_of_slotgroups = []
    slots.each do |slot|
      unless slot.slotgroup.nil?
        if not array_of_slotgroups.include?(slot.slotgroup)
          array_of_slotgroups << slot.slotgroup
        end
      end
    end
    return array_of_slotgroups
  end

  def set_slot_simulation_status_to_true(slots)
    slots.each do |slot|
      slot.simulation_status = true
      slot.save
    end
  end

  def set_slotgroup_simulation_status(slotgroups)
    slotgroups.each do |slotgroup|
      if Slot.where(slotgroup_id: slotgroup.id, simulation_status: true).count >0
        slotgroup.simulation_status = true
      end
    end
  end

end

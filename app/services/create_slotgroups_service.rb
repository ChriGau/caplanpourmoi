class CreateSlotgroupsService

  def initialize(slots)
    @slots = slots
  end

  def perform
    @slotgroups = create_slotgroups(@slots)
    calculate_caracteristics_slotgroups(@slotgroups)
    set_slot_simulation_status(@slots)
  end

  def create_slotgroups(slots)
    @slotgroups = []
    slots.each do |slot|
      # if slot unassigned to a slotgroup
      if Slot.find(slot.id).slotgroup_id.nil?
          # create new slotgroup
          @slotgroup = new_slotgroup(slot)
          @slotgroups << @slotgroup
          # assign similar slots to this slotgroup
          assign_slotgroup_to_slots(slot.similar_slots, @slotgroup)
      end
    end
    return @slotgroups
  end

  def calculate_caracteristics_slotgroups(slotgroups)
    slotgroups.each do |slotgroup|
      slotgroup.nb_required = slotgroup.nb_required
      slotgroup.nb_available = slotgroup.nb_skilled_and_available_users
      slotgroup.save
    end
  end

  def new_slotgroup(slot)
    # create a new slotgroup and assigns slotgroup_id to "mother slot"
    @slotgroup = Slotgroup.new
    @slotgroup.save
    slot.slotgroup_id = @slotgroup.id
    slot.save
    return @slotgroup
  end

  def assign_slotgroup_to_slots(slots, slotgroup)
    slotgroup.slots << slots
  end

  def set_slot_simulation_status(slots)
    slotgroups = get_array_of_slotgroups(slots)
    slotgroups.each do |slotgroup|
      if slotgroup.nb_available >= slotgroup.nb_required
        set_slot_simulation_status_to_true(slotgroup.slots)
      else
        nb_slots_to_simulate = slotgroup.nb_required - slotgroup.nb_available
        set_slot_simulation_status_to_true(slotgroup.slots.first(nb_slots_to_simulate))
      end
    end
  end

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

end

class CreateSlotgroupsService

  def initialize(slots)
    @slots = slots
  end

  def perform
    @slotgroups = create_slotgroups(@slots)
    calculate_caracteristics_slotgroups(@slotgroups)
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
      slotgroup.nb_available = slotgroup.set_nb_available_users
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

end

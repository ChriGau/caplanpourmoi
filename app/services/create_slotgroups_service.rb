# creates slotgroups from a collection of slots
# calculates the slotgroup's caracteristics
# determine each slot's simulation_status

# rubocop:disable LineLength, MethodLength, ClassLength

class CreateSlotgroupsService
  attr_accessor :slots_array, :planning, :users, :calcul, :slotgroups_array

  def initialize( attributes = {} )
    @slots_array = attributes[:slots_array] # [ {} , {} ]
    @planning = attributes[:planning]
    @users = @planning.users
    @calcul = attributes[:calcul_solution_v1_instance]
  end

  # rubocop:disable AbcSize

  def perform
    #timestamps t2
    t = @calcul.compute_solution.timestamps_algo << ["t2", Time.now]
    @calcul.compute_solution.update(timestamps_algo: t)
    # suite
    self.slotgroups_array = create_slotgroups # step 1.1.
    calculate_caracteristics_slotgroups # step 1.2. & 2
    determine_slots_simulation_status # step 2.
    determine_slotgroups_simulation_status(slotgroups_array) # step 2.
    determine_overlapping_slotgroups # step 3.1.
    determine_overlapping_users # step 3.2.
    fix_overlaps # step 3.3.
    determine_slots_simulation_status # step 3. (update)
    determine_slotgroups_simulation_status(slotgroups_array) # step 3. (update)
    determine_slots_to_simulate # step 3.
    determine_combinations_of_available_users # step 4.
    determine_ranking_algo # step 5.1.
    determine_calculation_interval # step 5.2.2.
    save_calcul_items(calcul, slotgroups_array)
    # timestamps t3
    t = @calcul.compute_solution.timestamps_algo << ["t3", Time.now]
    @calcul.compute_solution.update(timestamps_algo: t)
    # return les slotgroups qui ne sont pas à simuler
  end

  # rubocop:enable AbcSize

  def create_slotgroups
    slotgroups_array = []
    cpt_slotgroup = 0
    slots_array.each do |slot_hash|
      next unless slot_hash[:slotgroup_id].nil?
      cpt_slotgroup += 1
      slotgroup = Slotgroup.new(cpt_slotgroup, slot_hash[:slot_id])
      slotgroups_array << slotgroup
      assign_slotgroup_to_slots(Slot.find(slot_hash[:slot_id]).similar_slots, slotgroup.id)
    end
    slotgroups_array
  end

  def assign_slotgroup_to_slots(similar_slots, slotgroup_id)
    similar_slots.each do |slot|
      h = find_slot_instance_in_slots_array(slot.id)
      h[:slotgroup_id] = slotgroup_id unless h.nil?
    end
  end

  def calculate_caracteristics_slotgroups
    slotgroups_array.each do |slotgroup|
      slotgroup.determine_slotgroup_nb_required(slotgroup.id, slots_array)
      slotgroup.determine_slotgroup_availability(users)
    end
  end

  def determine_slots_simulation_status
    reset_slots_status_to_false
    slotgroups_array.each do |slotgroup|
      unless slotgroup.nb_available.zero?
        put_slots_simulation_status_to_x(get_similar_slots(slotgroup).first(slotgroup.determine_nb_slots_to_simulate), true)
      end
    end
  end

  def determine_slotgroups_simulation_status(slotgroups)
    slotgroups.class != Array ? slotgroups.determine_slotgroup_simulation_status : slotgroups.each(&:determine_slotgroup_simulation_status)
  end

  def determine_overlapping_slotgroups
    slotgroups_array.each do |slotgroup|
      l = slotgroups_array.select { |x| slotgroups_overlap?(slotgroup, x) && slotgroup.id != x.id }
      slotgroup.overlaps = l.map { |y| { slotgroup_id: y.id, users: [] } }.uniq
    end
  end

  # rubocop:disable AbcSize

  def determine_overlapping_users
    # list users which have no options but to be selected on 2 overlapping sg
    slotgroups_array.each do |slotgroup|
      next if slotgroup.nb_required != slotgroup.nb_available
      slotgroup.overlaps.each do |overlapping_slotgroups_array|
        overlapping_slotgroup_id = overlapping_slotgroups_array[:slotgroup_id]
        s = find_slotgroup_by_id(overlapping_slotgroup_id)
        next if s.nb_required != s.nb_available || s.role_id != slotgroup.role_id
        intersect = s.list_available_users & slotgroup.list_available_users
        next if intersect.empty? || !intersect.count.positive?
        overlapping_users_array = find_overlapping_users_array(slotgroup, overlapping_slotgroup_id)
        overlapping_users_array << intersect.flatten
        overlapping_users_array.flatten!
      end
    end
  end

  def fix_overlaps
    # TODO, define priorities per slotgroup (faked for now)
    slotgroups_array.sort_by!(&:priority)
    # record changes made so that user doesnt get unavailable for both slotgrps
    list_changes_made = []
    slotgroups_array.each do |slotgroup|
      slotgroup.overlaps.each do |slotgroup_overlaps_hash|
        next if slotgroup_overlaps_hash.nil?
        slotgroup_overlaps_hash[:users].each do |overlapping_user_id|
          # user gets unavailable for overlapping slotgroups
          overlapped_slotgroup = find_slotgroup_by_id(slotgroup_overlaps_hash[:slotgroup_id])
          # check if changes already made for this overlap
          unless list_changes_made.include?([overlapped_slotgroup.id, overlapping_user_id])
            overlapped_slotgroup.make_user_unavailable(overlapping_user_id)
          end
          list_changes_made << [slotgroup.id, overlapping_user_id]
        end
      end
    end
  end

  # rubocop:enable AbcSize

  def determine_slots_to_simulate
    slotgroups_array.each do |slotgroup|
      slotgroup.slots_to_simulate = similar_slots_to_simulate(slotgroup.id)
    end
  end

  def determine_combinations_of_available_users
    slotgroups_array.each do |slotgroup|
      slotgroup.nb_combinations_available_users = 0
      combinations_size = slotgroup.determine_nb_slots_to_simulate
      slotgroup.combinations_of_available_users = slotgroup.list_available_users.combination(combinations_size).to_a
      slotgroup.nb_combinations_available_users = slotgroup.combinations_of_available_users.count unless slotgroup.combinations_of_available_users[0].empty?
    end
  end

  def determine_ranking_algo
    # order slotgroups by decreasing nb_combinations_available_users
    cpt_ranking_algo = 1
    slotgroups_array.sort_by!(&:nb_combinations_available_users).reverse!
    slotgroups_array.each do |slotgroup|
      slotgroup.ranking_algo = cpt_ranking_algo
      cpt_ranking_algo += 1
    end
  end

  def determine_calculation_interval
    slotgroups_array.each do |slotgroup|
      calculation_interval = 1
      slotgroups_array.each do |slotgroup_bis|
        next if slotgroup.take_into_calculation_interval_account(slotgroup_bis)
        calculation_interval *= slotgroup_bis.nb_combinations_available_users
      end
      slotgroup.calculation_interval = calculation_interval
    end
  end

  def save_calcul_items(calcul_solution_v1_instance, slotgroups_array)
    calcul_solution_v1_instance.slotgroups_array = slotgroups_array
    calcul_solution_v1_instance.slots_array = slots_array
    calcul_solution_v1_instance.save
  end

  private

  def reset_slots_status_to_false
    slots_array.each do |x|
      x[:simulation_status] = false
    end
  end

  def get_similar_slots(slotgroup)
    # => [ { } , { } ]
    slots_array.select { |x| x[:slotgroup_id] == slotgroup.id }
  end

  def put_slots_simulation_status_to_x(slots_hashes, true_or_false)
    slots_hashes.each do |slot_hash|
      slot_hash[:simulation_status] = true_or_false
    end
  end

  def find_slot_instance_in_slots_array(slot_id)
    slots_array.find { |x| x[:slot_id] == slot_id }
  end

  def find_slotgroup_by_id(slotgroup_id)
    slotgroups_array.find { |x| x.id == slotgroup_id }
  end

  def find_overlapping_users_array(slotgroup, overlapping_slotgroup_id)
    slotgroup.overlaps.find { |x| x[:slotgroup_id] == overlapping_slotgroup_id }[:users]
  end

  def similar_slots_to_simulate(slotgroup_id)
    slots_array.select { |x| x[:slotgroup_id] == slotgroup_id && x[:simulation_status] == true }
  end

  def slotgroups_overlap?(slotgroup_one, slotgroup_two)
    # overlap if (start1 - end2) * (start1 - end2) > 0
    ((slotgroup_one.start_at - slotgroup_two.end_at) *
    (slotgroup_two.start_at - slotgroup_one.end_at)).positive?
  end
end

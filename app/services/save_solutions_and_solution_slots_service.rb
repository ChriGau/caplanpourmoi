# input =>
# output => creates instances of Solution and their associated SolutionSlots
class SaveSolutionsAndSolutionSlotsService

  def initialize(attributes = {})
    @slotgroups_array = attributes[:slotgroups_array] # contains also slotgroups not simulated
    @slots_array = attributes[:slots_array] # contains also slotgroups not simulated
    @planning = attributes[:planning]
    @compute_solution = attributes[:compute_solution] || nil
    @list_of_solutions = attributes[:list_of_solutions] || nil
    # list_of_solutions = [ { planning_possibility: [{sg_id: 1, combination: [1, 2]}, {...}], grade: 1}, {...} ]
    @no_solution_user_id = User.find_by(first_name: 'no solution').id
    @slots_not_to_simulate = attributes[:slots_not_to_simulate]
  end

  def perform
    # timestamp t6
    t = @compute_solution.timestamps_algo << ["t6", Time.now]
    @compute_solution.update(timestamps_algo: t)
    if !@list_of_solutions.nil?
      @list_of_solutions.each do |solution_hash|
        # solution_hash = { planning_possibility: [{sg_id: 1, combination: [1, 2]}, {...}], grade: 1}
        solution_instance = create_solution(solution_hash[:grade])
        solution_hash[:planning_possibility].each do |solution_sg_hash|
          # solution_sg_hash = { sg_id: 1, combination: [1, 2] }
          create_solution_slots(@slotgroups_array, solution_hash, solution_instance)
          create_no_solution_solution_slots(@slots_not_to_simulate, solution_instance)
          solution_instance.init
        end
      end
    else
      solution_instance = create_solution(solution.last)
      create_solution_slots_for_a_group_of_slots(@planning.slots.pluck(:id), solution_instance)
      solution_instance.init
    end
    # timestamp t7
    t = @compute_solution.timestamps_algo << ["t7", Time.now]
    @compute_solution.update(timestamps_algo: t)
    # evaluate metrics for algo statistics
    @compute_solution.evaluate_statistics
  end

  def create_solution(grade)
    Solution.create(planning: @planning, compute_solution: @compute_solution, grade: grade.round(3))
    # TODO add after_create => nb conflicts
  end

  def create_solution_slots(slotgroups_array, solution_hash, solution_instance)
    # on reprend tous les slotgroups (même à ne pas simuler)
    # solution_hash = { planning_possibility: [{sg_id: 1, combination: [1, 2]}, {...}], grade: 1}
    slotgroups_array.each do |slotgroup_instance|
      # si simulation_status = false, user = no solution
      if slotgroup_instance.simulation_status == false
        # récupérer les id des slots liés à ce slotgroup
        slots_id_array = get_array_of_ids_of_slots_related_to_a_slotgroup(slotgroup_instance.id, slotgroups_array)
        # créer les instances de slot_solutions avec user_id = 'no solution'
        create_solution_slots_for_a_group_of_slots(slots_id_array, solution_instance)
      # si required >= available => affecter à chacun des slots les users de la combination
      elsif slotgroup_instance.nb_available >= slotgroup_instance.nb_required
        slots_id_array = get_array_of_ids_of_slots_related_to_a_slotgroup(slotgroup_instance.id, slotgroups_array)
        combination = get_slotgroup_combination(solution_hash, slotgroup_instance)
        create_solution_slots_for_a_group_of_slots(slots_id_array, solution_instance, combination)
      # sinon (il y a des slots à simuler et d'autres non)
      else

        slots_id_array_false = get_array_of_slots_ids_related_to_slotgroup_id_according_to_simulation_status(false, slotgroup_instance.id, @slots_array)
        slots_id_array_true = get_array_of_slots_ids_related_to_slotgroup_id_according_to_simulation_status(true, slotgroup_instance.id, @slots_array)
        # leur affecter les users de la combination
        combination = get_slotgroup_combination(solution_hash, slotgroup_instance)
        create_solution_slots_for_a_group_of_slots(slots_id_array_true, solution_instance, combination)
        create_solution_slots_for_a_group_of_slots(slots_id_array_false, solution_instance)
      end
    end
  end

  def create_solution_slots_from_a_group_of_slots_and_solution_combinations(slots_id_array, solution_instance, combination)
      # recupérer la combination
        combination = get_slotgroup_combination(planning_possibility, slotgroup_instance)
        # prendre tous les slots à simuler = true (en toute logique cela correspond au nombre de users dans la combination)
        slots_id_array = get_array_of_slots_ids_related_to_slotgroup_id_according_to_simulation_status(true, slotgroup_instance.id, @slots_array)
        # leur affecter les users de la combination
        create_solution_slots_for_a_group_of_slots(slots_id_array, solution_instance, users)
  end

  private

  def get_array_of_ids_of_slots_related_to_a_slotgroup(slotgroup_id, slotgroups_array)
    slotgroups_array.select { |x| x.id == slotgroup_id }.first.slots_to_simulate.map{ |x| x[:slot_id] }
    # get_slots_related_to_a_slotgroup(slotgroup_id, slots_array).map { |x| x[:slot_id] }
  end

  def get_slots_related_to_a_slotgroup(slotgroup_id, slots_array)
    # => [ {:slotgroup_id, :simulation_status, :slot_instance}, {} ]
    slots_array.select { |x| x[:slotgroup_id] == slotgroup_id }
  end

  def get_slotgroup_combination(solution_hash, slotgroup_instance)
    # => Array of users' ids
    # solution_hash = { planning_possibility: [{sg_id: 1, combination: [1, 2]}, {...}], grade: 1}
    solution_hash[:planning_possibility].select { |x| x[:sg_id] == slotgroup_instance.id }.first[:combination]
  end

  def get_array_of_slots_ids_related_to_slotgroup_id_according_to_simulation_status(simulation_status, slotgroup_id, slots_array)
    get_slots_related_to_slotgroup_id_according_to_simulation_status(simulation_status, slotgroup_id, slots_array).map { |x| x[:slot_id] }
  end

  def get_slots_related_to_slotgroup_id_according_to_simulation_status(simulation_status, slotgroup_id, slots_array)
    slots_array.select { |x| x[:slotgroup_id] == slotgroup_id && x[:simulation_status] == simulation_status }
  end

  def create_solution_slots_for_a_group_of_slots(slots_id_array, solution_instance, users = [@no_solution_user_id], sequence = 0)
      return if sequence == slots_id_array.length
      create_solution_slot_instance(slots_id_array[sequence], users[sequence], solution_instance)
      create_solution_slots_for_a_group_of_slots(slots_id_array, solution_instance, users, sequence +=1)
  end

  def create_solution_slot_instance(slot_id, user_id, solution_instance)
    s = SolutionSlot.create(solution: solution_instance, :slot_id => slot_id, user_id: user_id)
    # TODO, s.extra_hours
  end

  def create_no_solution_solution_slots(slots_not_to_simulate, solution_instance)
    unless slots_not_to_simulate.empty?
      slots_not_to_simulate.each do |slot_id|
        SolutionSlot.create(solution: solution_instance, :slot_id => slot_id, user_id: @no_solution_user_id)
      end
    end
  end
end

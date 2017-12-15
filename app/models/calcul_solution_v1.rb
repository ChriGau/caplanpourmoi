class CalculSolutionV1 < ApplicationRecord
  attr_accessor :planning, :calcul_arrays, :build_solutions, :solution

  def initialize(planning)
    super({})
    @planning = planning
  end

  # rubocop:disable LineLength, MethodLength, AbcSize

  def perform
    slots = planning.slots
    # step_ 1
    initialized_slots_array = initialize_slots_array(slots) # => [ {} , {} ]
    # step 2
    self.calcul_arrays = CreateSlotgroupsService.new(initialized_slots_array, planning, self).perform
    # step 3
    to_simulate_slotgroups_arrays = select_slotgroups_to_simulate(calcul_arrays[:slotgroups_array])
    # step 4: go through plannings possibilities, assess them, select best solution.
    # pre-requisite: we must have some slotgroups to simulate.
    if not to_simulate_slotgroups_arrays.empty?
      build_solutions = GoFindSolutionsV1Service.new(planning, self, to_simulate_slotgroups_arrays).perform
      # step 5: créer une solution
      self.solution = create_solution(best_solution_hash[:nb_overlaps], :fresh)
      # step 6: créer des solution_slots à partir de la best solution => on traite les slotgroups "à simuler"
      create_solution_slots(calcul_arrays[:slotgroups_array], build_solutions[:best_solution][:planning_possibility])
      # update return variables
      test_possibilities = build_solutions[:test_possibilities]
      solutions_array = build_solutions[:solutions_array]
      best_solution = build_solutions[:best_solution]
      calculation_abstract = build_solutions[:calculation_abstract]
    else
      # 0 slotgroups to simulate
      self.solution = create_solution(nil, :fresh)
      create_solution_slots_when_no_slotgroup_to_simulate
      # update return variables
      test_possibilities = nil
      solutions_array = nil
      best_solution = nil
      calculation_abstract = nil
    end

    { calcul_arrays: calcul_arrays,
      test_possibilities: test_possibilities,
      solutions_array: solutions_array,
      best_solution: best_solution,
      calculation_abstract: calculation_abstract }
  end

  def initialize_slots_array(slots)
    slots.map(&:initialize_slot_hash)
  end

  def select_slotgroups_to_simulate(slotgroups_array)
    a = []
    slotgroups_array.each do |slotgroup|
      a << slotgroup if slotgroup.simulation_status == true
    end
    a
  end

  def create_solution(nb_overlaps, simulation_status)
    # creates an instance of solution
    solution = Solution.new
    solution.calculsolutionv1_id = self.id
    solution.planning_id = planning.id
    solution.nb_overlaps = nb_overlaps
    solution.status = simulation_status
    solution.save
    return solution
  end

  def create_solution_slots(slotgroups_array, planning_possibility)
    # on reprend tous les slotgroups (même à ne pas simuler) : (par odre de ranking_algo)
    slotgroups_array.each do |slotgroup_instance|
      # si simulation_status = false, user = no solution
      if slotgroup_instance.simulation_status == false
        # récupérer les id des slots liés à ce slotgroup
        slots_id_array = get_slots_related_to_a_slotgroup(slotgroup_instance.id, calcul_arrays[:slots_array]).map { |x| x[:slot_instance].id }
        # créer les instances de slot_solutions avec user_id = 'no solution'
        slots_id_array.each do |slot_id|
          create_solution_slot_instance(slot_id, User.find_by(first_name: 'no solution').id)
        end
      # si required >= available => affecter à chacun des slots les users de la combination
      elsif slotgroup_instance.nb_available >= slotgroup_instance.nb_required
        # récupérer les id des slots liés à ce slotgroup
        slots_id_array = get_slots_related_to_a_slotgroup(slotgroup_instance.id, calcul_arrays[:slots_array]).map { |x| x[:slot_instance].id }
        # récupérer la combination
        combination = planning_possibility.select { |x| x[:sg_id] == slotgroup_instance.id }.first[:combination]
        user_solution_position = 0
        slots_id_array.each do |slot_id|
          create_solution_slot_instance(slot_id, combination[user_solution_position].id)
          user_solution_position += 1
        end
      # sinon (il y a des slots à simuler et d'autres non)
      else
        # prendre tous les slots à simuler = true (en toute logique cela correspond au nombre de users dans la combination)
        slots_id_array = get_slots_related_to_slotgroup_id_according_to_simulation_status(true, slotgroup_instance.id, calcul_arrays[:slots_array]).map { |x| x[:slot_instance].id }
        # leur affecter les users de la combination
        combination = planning_possibility.select { |x| x[:sg_id] == slotgroup_instance.id }.first[:combination]
        user_solution_position = 0
        slots_id_array.each do |slot_id|
          create_solution_slot_instance(slot_id, combination[user_solution_position].id)
          user_solution_position += 1
        end
        # réaffecter 'no solution' aux slots à simuler = false
        slots_id_array = get_slots_related_to_slotgroup_id_according_to_simulation_status(false, slotgroup_instance.id, calcul_arrays[:slots_array]).map { |x| x[:slot_instance].id }
        # leur affecter les users de la combination
        combination = planning_possibility.select { |x| x[:sg_id] == slotgroup_instance.id }.first[:combination]
        slots_id_array.each do |slot_id|
            create_solution_slot_instance(slot_id, User.find_by(first_name: 'no solution').id)
        end
      end
    end
    # test : vérifier que l'on a crée autant de solution_slots que le planning ne contient de slots.
    # compter nombre de solution_slots créés
    nb_solution_slots = SolutionSlot.select { |x| x.solution.calculsolutionv1_id == self.id }.count
    # compter nombre de slots existants
    nb_slots = Slot.select { |x| x.planning_id == @planning.id }.count
  end

  def create_solution_slots_when_no_slotgroup_to_simulate
    # get slots_id related to the planning
    slots_id_array = planning.slots.map(&:id)
    slots_id_array.each do |slot_id|
      create_solution_slot_instance(slot_id, User.find_by(first_name: 'no solution').id)
    end
  end

  private

  def get_slots_related_to_a_slotgroup(slotgroup_id, slots_array)
    # => [ {:slotgroup_id, :simulation_status, :slot_instance}, {} ]
    slots_array.select { |x| x[:slotgroup_id] == slotgroup_id }
  end

  def get_slotgroup_combination(slotgroups_solutions_array, slotgroup_id)
    slotgroups_solutions_array.find { |x| x[:sg_id] == slotgroup_id }[:combination]
  end

  def find_slotgroup_by_id(slotgroup_id, slotgroups_array)
    slotgroups_array.find { |x| x.id == slotgroup_id }
  end

  def get_slots_related_to_slotgroup_id_according_to_simulation_status(simulation_status, slotgroup_id, slots_array)
    slots_array.select { |x| x[:slotgroup_id] == slotgroup_id && x[:simulation_status] == simulation_status }
  end

  def count_slots_related_to_slotgroup_id_according_to_simulation_status(simulation_status, slotgroup_id, slots_array)
    get_slots_related_to_slotgroup_id_according_to_simulation_status(simulation_status, slotgroup_id, slots_array).count
  end

  def create_solution_slot_instance(slot_id, user_id)
    s = SolutionSlot.new
    s.solution_id = solution.id
    s.slot_id = slot_id
    s.user_id = user_id
    # TODO, s.extra_hours
    s.save
  end

  def more_or_equal_available_as_required?(slotgroup_id, slotgroups_array)
    # returns true if available >= required users
    slotgroup = find_slotgroup_by_id(slotgroup_id, slotgroups_array)
    slotgroup.more_or_equal_available_as_required?
  end
end

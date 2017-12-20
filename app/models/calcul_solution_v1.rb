# == Schema Information
#
# Table name: calcul_solution_v1s
#
#  id               :integer          not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  slots_array      :text
#  slotgroups_array :text
#  information      :text
#

class CalculSolutionV1 < ApplicationRecord
  attr_accessor :planning, :calcul_arrays, :build_solutions, :solution

  def initialize(planning)
    super({})
    @planning = planning
    @no_solution_user = [User.find_by(first_name: 'no solution')]
  end

  # rubocop:disable LineLength, MethodLength, AbcSize

  def perform
    slots = planning.slots
    initialized_slots_array = initialize_slots_array(slots) # step 1
    self.calcul_arrays = CreateSlotgroupsService.new(initialized_slots_array, planning, self).perform # step 2
    puts 'CreateSlotgroupsService --> done'
    to_simulate_slotgroups_arrays = select_slotgroups_to_simulate(calcul_arrays[:slotgroups_array]) # step 3
    # step 4: go through plannings possibilities, assess them, select best solution. (2 cases)
    # there are some sg to simulate (case 1)
    if !to_simulate_slotgroups_arrays.empty?
      puts 'GoFindSolutionsV1Service --> initiated'
      build_solutions = GoFindSolutionsV1Service.new(planning, self, to_simulate_slotgroups_arrays).perform
      # step 5_case 1: mettre en mémoire la solution une solution
      puts 'GoFindSolutionsV1Service --> done. --> storing best solution'
      self.solution = create_solution(build_solutions[:best_solution][:nb_overlaps], :fresh)
      # step 6_case 1: créer des solution_slots à partir de la best solution
      create_solution_slots(calcul_arrays[:slotgroups_array], build_solutions[:best_solution][:planning_possibility])
      # update return variables
      test_possibilities = build_solutions[:test_possibilities]
      solutions_array = build_solutions[:solutions_array]
      best_solution = build_solutions[:best_solution]
      calculation_abstract = build_solutions[:calculation_abstract]
    else
      # 0 slotgroups to simulate (case 2)
      self.solution = create_solution(nil, :fresh) # step 5 case 2
      create_solution_slots_when_no_slotgroup_to_simulate # step 6 case 2
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
    solution.calculsolutionv1_id = id
    solution.planning_id = planning.id
    solution.nb_overlaps = nb_overlaps
    solution.status = simulation_status
    solution.save
    solution
  end

  def create_solution_slots(slotgroups_array, planning_possibility)
    # on reprend tous les slotgroups (même à ne pas simuler)
    slotgroups_array.each do |slotgroup_instance|
      # si simulation_status = false, user = no solution
      if slotgroup_instance.simulation_status == false
        # récupérer les id des slots liés à ce slotgroup
        slots_id_array = get_array_of_ids_of_slots_related_to_a_slotgroup(slotgroup_instance.id, calcul_arrays[:slots_array])
        # créer les instances de slot_solutions avec user_id = 'no solution'
        create_solution_slots_for_a_group_of_slots(slots_id_array)
      # si required >= available => affecter à chacun des slots les users de la combination
      elsif slotgroup_instance.nb_available >= slotgroup_instance.nb_required
        slots_id_array = get_array_of_ids_of_slots_related_to_a_slotgroup(slotgroup_instance.id, calcul_arrays[:slots_array])
        combination = get_slotgroup_combination(planning_possibility, slotgroup_instance)
        create_solution_slots_for_a_group_of_slots(slots_id_array, combination)
      # sinon (il y a des slots à simuler et d'autres non)
      else

        slots_id_array_false = get_array_of_slots_ids_related_to_slotgroup_id_according_to_simulation_status(false, slotgroup_instance.id, calcul_arrays[:slots_array])
        slots_id_array_true = get_array_of_slots_ids_related_to_slotgroup_id_according_to_simulation_status(true, slotgroup_instance.id, calcul_arrays[:slots_array])
        # leur affecter les users de la combination
        combination = get_slotgroup_combination(planning_possibility, slotgroup_instance)
        create_solution_slots_for_a_group_of_slots(slots_id_array_true, combination)
        create_solution_slots_for_a_group_of_slots(slots_id_array_false)
      end
    end
  end

  def create_solution_slots_from_a_group_of_slots_and_solution_combinations(slots_id_array, combination)
      # recupérer la combination
        combination = get_slotgroup_combination(planning_possibility, slotgroup_instance)
        # prendre tous les slots à simuler = true (en toute logique cela correspond au nombre de users dans la combination)
        slots_id_array = get_array_of_slots_ids_related_to_slotgroup_id_according_to_simulation_status(true, slotgroup_instance.id, calcul_arrays[:slots_array])
        # leur affecter les users de la combination
        create_solution_slots_for_a_group_of_slots(slots_id_array, users)
  end

  def create_solution_slots_when_no_slotgroup_to_simulate
    # get slots_id related to the planning
    slots_id_array = planning.slots.map(&:id)
    create_solution_slots_for_a_group_of_slots(slots_id_array)
  end

  private

  def get_array_of_ids_of_slots_related_to_a_slotgroup(slotgroup_id, slots_array)
    get_slots_related_to_a_slotgroup(slotgroup_id, slots_array).map { |x| x[:slot_instance].id }
  end

  def get_slots_related_to_a_slotgroup(slotgroup_id, slots_array)
    # => [ {:slotgroup_id, :simulation_status, :slot_instance}, {} ]
    slots_array.select { |x| x[:slotgroup_id] == slotgroup_id }
  end

  def get_slotgroup_combination(planning_possibility, slotgroup_instance)
    planning_possibility.select { |x| x[:sg_id] == slotgroup_instance.id }.first[:combination]
  end

  def get_array_of_slots_ids_related_to_slotgroup_id_according_to_simulation_status(simulation_status, slotgroup_id, slots_array)
    get_slots_related_to_slotgroup_id_according_to_simulation_status(simulation_status, slotgroup_id, slots_array).map { |x| x[:slot_instance].id }
  end

  def get_slots_related_to_slotgroup_id_according_to_simulation_status(simulation_status, slotgroup_id, slots_array)
    slots_array.select { |x| x[:slotgroup_id] == slotgroup_id && x[:simulation_status] == simulation_status }
  end

  def create_solution_slots_for_a_group_of_slots(slots_id_array, users = @no_solution_user, sequence = 0)
      return if sequence == slots_id_array.length
      create_solution_slot_instance(slots_id_array[sequence], users[sequence])
      create_solution_slots_for_a_group_of_slots(slots_id_array, users, sequence +=1)
  end

  def create_solution_slot_instance(slot_id, user)
    s = SolutionSlot.new
    s.solution_id = solution.id
    s.slot_id = slot_id
    s.user = user
    # TODO, s.extra_hours
    s.save
  end

  def no_solution_user_id
    User.find_by(first_name: 'no solution').id
  end
end

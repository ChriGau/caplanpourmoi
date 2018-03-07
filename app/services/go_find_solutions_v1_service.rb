# from slots_array and slotgroups_array, go through the combinations of
# plannings and selects appropriate solutions.

# rubocop:disable LineLength, MethodLength, AbcSize, ClassLength

class GoFindSolutionsV1Service
  attr_accessor :planning, :calcul, :slotgroups_array, :users,
                :nb_trees, :nb_branches, :nb_slotgroups,
                :build_solutions, :planning_possibility,
                :iteration_id, :solutions_array

  def initialize(planning, calcul_solution_v1_instance, slotgroups_array)
    @planning = planning
    @calcul = calcul_solution_v1_instance
    @slotgroups_array = slotgroups_array
    @users = @planning.users
  end

  def perform
    # calculate pre-requisites to plannings iterating
    self.nb_trees = determine_number_of_trees
    self.nb_branches = determine_number_of_branches
    self.nb_slotgroups = slotgroups_array.count
    # iterate through planning possibilities to extract solutions
    self.build_solutions = go_through_plannings
    # select the best solutions
    build_solutions[:best_solution] = pick_best_solutions(build_solutions[:solutions_array], 15)
    # return
    build_solutions
  end

  def determine_number_of_trees
    slotgroups_array.find { |x| x.ranking_algo == 1 }.nb_combinations_available_users
  end

  def determine_number_of_branches
    nb_branches = 1
    slotgroups_array.each do |slotgroup|
      unless slotgroup.take_into_calculation_nb_branches_account
        nb_branches *= slotgroup.nb_combinations_available_users
      end
    end
    nb_branches
  end

  # rubocop:disable For

  def go_through_plannings
    # @planning_possibility = [ {sg_id: 1, combi: [combination of users]} , {...} ]
    test_possibilities = []
    solution_id = 0
    self.solutions_array = []
    overlaps_best_scoring = init_overlaps_best_scoring
    possibility_id = 0
    iteration_id = 0
    nb_cuts_within_tree = 0
    next_tree = nil
    next_branch = nil
    for tree in 1..nb_trees
      for branch in 1..nb_branches
        self.planning_possibility = []
        # next if solution_id ==  1000  # pour stopper les itérations au bout de la nième solution
        # we skip this branch if we must
        next if must_we_jump_to_another_branch?(tree, next_tree, branch, next_branch)
        # let's build a planning possibility
        for sg_ranking in 1..nb_slotgroups # slotgroups rankings
          position = identify_position(tree, branch, sg_ranking)
          combination = identify_slotgroup_combination(position, sg_ranking)
          slotgroup_id = find_slotgroup_by_ranking(sg_ranking).id
          planning_possibility << { sg_ranking: sg_ranking,
                                    sg_id: slotgroup_id,
                                    combination: combination,
                                    overlaps: nil }
        end
        # *** now we have a planning_possibility which contains a possibility of planning ***
        possibility_id += 1
        result_overlaps_check = evaluate_overlaps_for_a_planning(planning_possibility, overlaps_best_scoring)
        if result_overlaps_check[:success]
          overlaps_best_scoring = result_overlaps_check[:nb_overlaps_of_a_planning]
          # TODO, evaluate weekly hours respect
          # store solution
          solution_id += 1
          solutions_array << { solution_id: solution_id,
                               possibility_id: possibility_id,
                               nb_overlaps: overlaps_best_scoring,
                               planning_possibility: planning_possibility,
                               nb_conflicts: nil }
        else
          # cut off all similar possibilities
          next_knot_caracteristics = go_to_next_knot(tree, branch, result_overlaps_check[:sg_ranking_where_overlap_evaluation_is_lower_than_best])
          next_tree = next_knot_caracteristics[:tree]
          next_branch = next_knot_caracteristics[:branch]
          nb_cuts_within_tree += 1
        end
        iteration_id += 1
        test_possibilities << planning_possibility
      end
    end
    calculation_abstract = determine_calculation_abstract(iteration_id, nb_cuts_within_tree)
    { test_possibilities: test_possibilities,
      solutions_array: solutions_array,
      best_solution: nil,
      calculation_abstract: calculation_abstract }
  end

  # rubocop:enable For

def pick_best_solutions(solutions_array, how_many_solutions_do_we_store)
    # Selects X solutions from a collection of solutions.
    # several solutions with 0 overlaps? => pick the last X ones
    # else, we pick the last X ones and update the overlaps == 'no solution'
    collection_no_overlaps = collect_solutions_with_no_overlap(solutions_array)
    size_selection_solutions = how_many_solutions_do_we_store
    if collection_no_overlaps.count.positive?
      # if more optimal solutions than size of our top => pick the last size_selection_solutions ones
      if collection_no_overlaps.count >= size_selection_solutions
        return collection_no_overlaps.last(size_selection_solutions)
      else
        # pick the 1..size_selection_solutions ones
        return collection_no_overlaps
      end
    else # if no optimal solutions
      # if more solutions than size of our top
      if solutions_array.count >= size_selection_solutions
        # select the last X ones
        solutions_array.last(size_selection_solutions).each do |partial_solution|
          # fix overlaps => assign user according to slotgroups priority
          # assign_no_solution_user_for_sg_with_overlaps(partial_solution) => non, fait dans un autre service
        end
        return solutions_array.last(size_selection_solutions)
      else # less than 'size_selection_solutions' partial solutions
        # select as many solutions as there are, and fix them
        solutions_array.each do |partial_solution|
          # assign_no_solution_user_for_sg_with_overlaps(partial_solution) => non, fait dans un autre service
        end
        return solutions_array
      end
    end
  end

  # rubocop:enable GuardClause

  def determine_calculation_abstract(iteration_id, nb_cuts_within_tree)
    { nb_solutions: calculate_nb_solutions,
      nb_optimal_solutions: calculate_nb_optimal_solutions,
      nb_iterations: iteration_id,
      nb_possibilities_theory: nb_trees * nb_branches,
      nb_cuts_within_tree: nb_cuts_within_tree,
      calculation_length_seconds: 'todo' }
  end

  def go_to_next_knot(tree, branch, sg_ranking)
    nb_possibilities_below_this_knot = calculate_nb_possibilities_below_this_knot(sg_ranking)
    if sg_ranking == 1
      branch = 1
      tree += 1
    elsif (sg_ranking >= 2) && (sg_ranking <= nb_slotgroups - 1)
      branch += nb_possibilities_below_this_knot - 1
    end
    { branch: branch, tree: tree }
  end

  private

  def init_overlaps_best_scoring
    # max of overlaps = all users are in overlap for all sg
    users.count * nb_slotgroups
  end

  def must_we_jump_to_another_branch?(tree, next_tree, branch, next_branch)
    ((tree == next_tree) && (branch < next_branch)) ||
      ((tree + 1 == next_tree) && (branch < next_branch))
  end

  # rubocop:disable UselessAssignment, PerceivedComplexity, CyclomaticComplexity

  def identify_position(tree, branch, sg_ranking)
    # position = for each slotgroup, which one of the combinations of available
    # users are we at? ("itérateur_position" dans ma doc)
    # interval_position = "numéro_intervalle" dans ma doc
    position = 0 # init
    slotgroup = find_slotgroup_by_ranking(sg_ranking)
    if tree != 1 && sg_ranking == 1
      position = nb_trees
    elsif branch == 1 || sg_ranking == 1 ||
          slotgroup.nb_combinations_available_users == 1 ||
          (slotgroup.nb_combinations_available_users == 1 && slotgroup.calculation_interval == 1)
      position = 1
    elsif slotgroup.calculation_interval == 1 && slotgroup.nb_combinations_available_users > 1
      interval_position = slotgroup.calculate_interval_position(branch, true)
      position = slotgroup.calculate_position(branch, interval_position, true)
    else
      interval_position = slotgroup.calculate_interval_position(branch, false)
      position = slotgroup.calculate_position(branch, interval_position, false)
    end
  end

  # rubocop:enable UselessAssignment, Cyclomaticomplexity

  def find_slotgroup_by_id(slotgroup_id)
    slotgroups_array.find { |x| x.id == slotgroup_id }
  end

  def find_slotgroup_by_ranking(ranking)
    slotgroups_array.find { |x| x.ranking_algo == ranking }
  end

  def identify_slotgroup_combination(position, sg_ranking)
    # we need the combination of users #position for this sg
    slotgroup = find_slotgroup_by_ranking(sg_ranking)
    slotgroup.combinations_of_available_users[position - 1]
  end

  def evaluate_overlaps_for_a_planning(planning, overlaps_best_scoring)
    # returns true if better than overlaps_best_scoring + scoring (=nb of overlaps)
    success = false
    overlaps = 0
    sg_ranking_where_overlap_evaluation_is_lower_than_best = nil
    planning.each do |slotgroup_possibility|
      # result = { :nb_overlaps_slotgroup, :slotgroup_possibility }
      result = evaluate_overlaps_for_a_slotgroup_possibility(slotgroup_possibility)
      overlaps += result[:nb_overlaps_slotgroup]
      if overlaps_equal_zero_or_lower_than_best?(overlaps, overlaps_best_scoring)
        success = true
      else
        success = false
        # memorize sg_id which makes us break out of loop - so that we can skip all possibilities below this knot.
        # this is the max of all
        sg_ranking_where_overlap_evaluation_is_lower_than_best = slotgroup_possibility[:sg_id]
        break
      end
    end
    { success: success,
      nb_overlaps_of_a_planning: overlaps,
      sg_ranking_where_overlap_evaluation_is_lower_than_best:
      sg_ranking_where_overlap_evaluation_is_lower_than_best }
  end

  def evaluate_overlaps_for_a_slotgroup_possibility(slotgroup_possibility)
    # does this slotgroup_possibility overlap other slotgroups? are there
    # any users working simultaneously on those slotgroups?
    slotgroup = find_slotgroup_by_id(slotgroup_possibility[:sg_id])
    slotgroup_possibility_combination = slotgroup_possibility[:combination]
    # init
    nb_overlaps_slotgroup = 0
    users_in_overlap = []
    slotgroup_possibility_overlaps_array = []
    # check for each theoretical overlap if it is the case in pratice
    slotgroup.overlaps.each do |overlapping_slotgroup_hash|
      users_in_overlap = [] # reinit
      overlapped_slotgroup_id = overlapping_slotgroup_hash[:slotgroup_id]
      # on passe au suivant si l'overlap concerne un slotgroup qui n'est pas simulé
      # càd que l'on ne trouve pas ce slotgroup.
      next if find_slotgroup_possibility_by_id(overlapped_slotgroup_id).nil?
      overlapped_slotgroup_possibility = find_slotgroup_possibility_by_id(overlapped_slotgroup_id)
      users_in_overlap = slotgroup_possibility_combination & overlapped_slotgroup_possibility[:combination]
      unless users_in_overlap.nil? || users_in_overlap.empty?
        nb_overlaps_slotgroup += users_in_overlap.flatten.count
        slotgroup_possibility_overlaps_array << { sg_id: overlapped_slotgroup_id, users: users_in_overlap.flatten }
      end
    end
    # update slotgroup_possibility[:overlaps]
    slotgroup_possibility[:overlaps] = slotgroup_possibility_overlaps_array
    { nb_overlaps_slotgroup: nb_overlaps_slotgroup, slotgroup_possibility: slotgroup_possibility }
  end

  def find_slotgroup_possibility_by_id(slotgroup_id)
    planning_possibility.find { |x| x[:sg_id] == slotgroup_id }
  end

  def overlaps_equal_zero_or_lower_than_best?(overlaps, overlaps_best_scoring)
    overlaps.zero? || overlaps <= overlaps_best_scoring
  end

  def collect_solutions_with_no_overlap(solutions_array)
    solutions_array.select { |x| x[:nb_overlaps].zero? }
  end

  def calculate_nb_solutions
    solutions_array.count
  end

  def calculate_nb_optimal_solutions
    # count nb of items with no overlaps
    # TODO, update this method when weekly hours check will be set up
    solutions_array.select { |x| x[:nb_overlaps].zero? }.count
  end

  def calculate_nb_possibilities_below_this_knot(sg_ranking)
    nb_possibilities = 1
    slotgroups_array.each do |slotgroup|
      if slotgroup.ranking_algo > sg_ranking && (slotgroup.simulation_status == true)
        nb_possibilities *= slotgroup.nb_combinations_available_users
      end
    end
    nb_possibilities
  end

  def assign_no_solution_user_for_sg_with_overlaps(solutions_array)
    # we have a solution_array which contains overlaps. This solution has been
    # selected as one of the best ones. We need to update the combinations so that the
    # one which is in overlap => no solution
    # solutions_array = [ {:solution_id, :possibility_id, :nb_overlaps, :planning_possibility} ]
    # :planning_possibility => {:sg_ranking, :sg_id, :combination, :overlaps}
    solutions_array[:planning_possibility].each do |possibility_hash|
      combination = possibility_hash[:combination]
      possibility_hash[:overlaps].each do |overlap|
        # sur chacun des overlaps, on passe chacun des users en overlap en 'no solution'.
        # TODO, il faudrait stocker qqpart pourquoi ce slot n'a pas de solution
        # en notant le sg avec lequel il est en overlap + le user concerné.
        overlap[:users].each do |user|
          if combination.include?(user)
            position_of_overlapping_user_in_combination = combination.index(user)
            possibility_hash[:combination][position_of_overlapping_user_in_combination] = determine_no_solution_user
          end
        end
      end
    end
end

  def determine_no_solution_user
    User.find_by(first_name: 'no solution')
  end
end

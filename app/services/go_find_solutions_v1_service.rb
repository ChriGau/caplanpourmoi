# from slots_array and slotgroups_array, go through the combinations of
# plannings and selects appropriate solutions.

# rubocop:disable LineLength, MethodLength, ClassLength

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
    # @build_solutions = { test_possibilities: test_possibilities, solutions_array: solutions_array, best_solution : nil à ce stade, calculation_abstract: calculation_abstract }
    self.build_solutions = go_through_plannings
    # we now have a collection of solutions. We need to select one.
    build_solutions[:best_solution] = pick_best_solution(build_solutions[:solutions_array])
    return build_solutions
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
    return nb_branches
  end

  def go_through_plannings
    # @planning_possibility = [ {sg_id: 1, combi: [combination of users]} , etc. ]
    test_possibilities = []
    solutions = []
    solution_id = 0
    self.solutions_array = []
    overlaps_best_scoring = init_overlaps_best_scoring
    possibility_id = 0
    iteration_id = 0
    cutoff = 0
    next_tree = nil
    next_branch = nil
    for tree in 1..nb_trees
      for branch in 1..nb_branches
        # re init
        self.planning_possibility = []
        # check if we must next
        if tree == next_tree
            next if branch < next_branch
        elsif tree + 1 == next_tree
          next if branch < next_branch
        end
        for sg_ranking in 1..nb_slotgroups # slotgroups rankings
          position = identify_position(tree, branch, sg_ranking)
          combination = identify_slotgroup_combination(position, sg_ranking)
          slotgroup_id = find_slotgroup_by_ranking(sg_ranking).id
          planning_possibility << { sg_ranking: sg_ranking,
                                    sg_id: slotgroup_id ,
                                    combination: combination,
                                    overlaps: nil }
        end
        # *** now we have @planning_possibility which contains a possibility of planning ***
        possibility_id += 1
        # evaluate overlapping users
        # result_overlaps_check = { :success ,:nb_overlaps_of_a_planning: nb_overlaps_of_a_planning,
        # sg_ranking_where_overlap_evaluation_is_lower_than_best }
        result_overlaps_check = overlapping_evaluation_for_a_planning_is_better_or_equal_than_best?(overlaps_best_scoring)
        # si ce planning est meilleur que le best
        if result_overlaps_check[:success]
          # update overlaps_best_scoring
          overlaps_best_scoring = result_overlaps_check[:nb_overlaps_of_a_planning]
          # TODO, evaluate weekly hours respect
          # store solution
          solution_id += 1
          solutions_array << { solution_id: solution_id,
                              possibility_id: possibility_id,
                              nb_overlaps: overlaps_best_scoring ,
                              planning_possibility: planning_possibility }
        else
          # cut off all the possibilities
          next_knot_caracteristics = go_to_next_knot(tree, branch, result_overlaps_check[:sg_ranking_where_overlap_evaluation_is_lower_than_best])
          next_tree = next_knot_caracteristics[:tree]
          next_branch = next_knot_caracteristics[:branch]
          cutoff += 1
        end
        iteration_id += 1
        test_possibilities << planning_possibility
      end
    end
    calculation_abstract = determine_calculation_abstract(iteration_id)
    return { test_possibilities: test_possibilities,
            solutions_array: solutions_array,
            best_solution: nil,
            calculation_abstract: calculation_abstract }
  end

  def pick_best_solution(solutions_array)
    # we have a collection of solutions. We need to select one.
    # if several have 0 overlaps, choose randomly among those.
    # else, we pick the last one.
    collection_no_overlaps = collect_solutions_with_no_overlap(solutions_array)
    unless collection_no_overlaps.count.zero?
      random_choice = rand(1..collection_no_overlaps.count)
      return collection_no_overlaps[random_choice - 1]
    else
      return solutions_array.last
    end
  end

  def determine_calculation_abstract(iteration_id)
    # => { :nb_solutions, :nb_optimal_solutions, :nb_iterations,
    # :nb_possibilities, :calculation_length_seconds }
    { nb_solutions: calculate_nb_solutions,
      nb_optimal_solutions: calculate_nb_optimal_solutions,
      nb_iterations: iteration_id,
      nb_possibilities_theory: nb_trees * nb_branches,
      calculation_length_seconds: "todo" }
  end

  def go_to_next_knot(tree, branch, sg_ranking)
    nb_possibilities_below_this_knot = calculate_nb_possibilities_below_this_knot(sg_ranking)
    if sg_ranking == 1
      branch = 1
      tree += 1
    elsif (sg_ranking >= 2) and (sg_ranking <= nb_slotgroups - 1)
      branch += nb_possibilities_below_this_knot - 1
    end
    return { branch: branch, tree: tree }
  end

private

  def init_overlaps_best_scoring
    # max of overlaps = all users are in overlap for all sg
    users.count * nb_slotgroups
  end

  def identify_position(tree, branch, sg_ranking)
    # position = for each slotgroup, which one of the combinations of available
    # users are we at?
    # position = "itérateur_position" dans ma doc
    # interval_position = "numéro=_intervalle" dans ma doc
    position = 0 # init
    slotgroup = find_slotgroup_by_ranking(sg_ranking)
    if tree != 1 && sg_ranking == 1
      position = nb_trees
    else
      if branch == 1 || sg_ranking == 1 || slotgroup.nb_combinations_available_users == 1 ||
      (slotgroup.nb_combinations_available_users == 1 && slotgroup.calculation_interval == 1)
      position = 1
      else
        # numéro_intervalle <=> interval_position. position <=> itérateur_position dans ma doc.
        if slotgroup.calculation_interval == 1 && slotgroup.nb_combinations_available_users > 1
          interval_position = slotgroup.calculate_interval_position(branch, true)
          position = slotgroup.calculate_position(branch, interval_position, true)
        else
          interval_position = slotgroup.calculate_interval_position(branch, false)
          position = slotgroup.calculate_position(branch, interval_position, false)
        end
      end
    end
  end

  def find_slotgroup_by_id(slotgroup_id)
    slotgroups_array.find { |x| x.id == slotgroup_id }
  end

  def find_slotgroup_by_ranking(ranking)
    slotgroups_array.find { |x| x.ranking_algo == ranking }
  end

  def identify_slotgroup_combination(position, sg_ranking)
    # we need the combination of users #position for this sg
    slotgroup = find_slotgroup_by_ranking(sg_ranking)
    combination = slotgroup.combinations_of_available_users[position - 1]
  end

  def overlapping_evaluation_for_a_planning_is_better_or_equal_than_best?(overlaps_best_scoring)
    success = false
    nb_overlaps_of_a_planning = 0
    sg_ranking_where_overlap_evaluation_is_lower_than_best = nil
    evaluation_result = evaluate_overlaps_for_a_planning(planning_possibility, overlaps_best_scoring)
    if evaluation_result[:success] == true
      nb_overlaps_of_a_planning = evaluation_result[:scoring]
      success = nb_overlaps_of_a_planning.zero? || nb_overlaps_of_a_planning <= overlaps_best_scoring
    else
      sg_ranking_where_overlap_evaluation_is_lower_than_best = evaluation_result[:sg_ranking_where_overlap_evaluation_is_lower_than_best]
    end
    { success: success,
      nb_overlaps_of_a_planning: nb_overlaps_of_a_planning,
      sg_ranking_where_overlap_evaluation_is_lower_than_best: sg_ranking_where_overlap_evaluation_is_lower_than_best }
  end

  def evaluate_overlaps_for_a_planning(planning, overlaps_best_scoring)
    # returns true if better than overlaps_best_scoring + scoring (=nb of overlaps)
    success = false
    overlaps = 0
    sg_ranking_where_overlap_evaluation_is_lower_than_best = nil
    planning.each do |slotgroup_possibility|
      # result = { nb_overlaps_slotgroup: nb_overlaps_slotgroup, slotgroup_possibility: slotgroup_possibility }
      result = evaluate_overlaps_for_a_slotgroup_possibility(slotgroup_possibility)
      overlaps += result[:nb_overlaps_slotgroup]
      # we checked all the overlaps on all sg of this planning.
      if overlaps_equal_zero_or_lower_than_best?(overlaps, overlaps_best_scoring)
        success = true
      else
        success = false
        # memorize sg_id which makes us break out of loop so that
        # we can skip all possibilities below this knot.
        sg_ranking_where_overlap_evaluation_is_lower_than_best = slotgroup_possibility[:sg_id]
        break
      end
    end
    return { success: success, scoring: overlaps,
      sg_ranking_where_overlap_evaluation_is_lower_than_best: sg_ranking_where_overlap_evaluation_is_lower_than_best }
  end

  def evaluate_overlaps_for_a_slotgroup_possibility(slotgroup_possibility)
    # does this slotgroup_possibility overlap another slotgroup?
    # => get intersection of overlapping users if any.
    # => return nb of overlaps + updated slotgroup_possibility
    # identify slotgroup of this slotgroup_possibility
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
      # binding.pry
      overlapped_slotgroup_possibility = find_slotgroup_possibility_by_id(overlapped_slotgroup_id)
      users_in_overlap = slotgroup_possibility_combination & overlapped_slotgroup_possibility[:combination]
      # si on a une intersection
      unless users_in_overlap.nil? || users_in_overlap.empty?
        # update compteur d'overlaps
        nb_overlaps_slotgroup += users_in_overlap.flatten.count
        # upate slotgroup_possibility attributes
        slotgroup_possibility_overlaps_array << { sg_id: overlapped_slotgroup_id, users: users_in_overlap.flatten }
      end
    end
    # update slotgroup_possibility[:overlaps]
    slotgroup_possibility[:overlaps] = slotgroup_possibility_overlaps_array
    # on retourne le slotgroup_possibility updaté + le nombre d'overlaps pour ce sg
    { nb_overlaps_slotgroup: nb_overlaps_slotgroup, slotgroup_possibility: slotgroup_possibility }
  end

  def find_slotgroup_possibility_by_id(overlapping_slotgroup_id)
    planning_possibility.find { |x| x[:sg_id] == overlapping_slotgroup_id }
  end

  def overlaps_equal_zero_or_lower_than_best?(overlaps, overlaps_best_scoring)
    overlaps.zero? || overlaps < overlaps_best_scoring
  end

  def collect_solutions_with_no_overlap(solutions_array)
    solutions_array.select { |x| x[:nb_overlaps] == 0 }
  end

  def calculate_nb_solutions
    # count nb of items within solutions_array
    solutions_array.count
  end

  def calculate_nb_optimal_solutions
    # count nb of items with no overlaps
    # TODO, update this method when weekly hours ckeck will be set up
    solutions_array.select { |x| x[:nb_overlaps] == 0 }.count
  end

  def calculate_nb_possibilities_below_this_knot(sg_ranking)
    nb_possibilities = 1
    slotgroups_array.each do |slotgroup|
      if slotgroup.ranking_algo > sg_ranking && (slotgroup.simulation_status == true)
        nb_possibilities *= slotgroup.nb_combinations_available_users
      end
    end
    return nb_possibilities
  end
end

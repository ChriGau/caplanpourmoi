# from slots_array and slotgroups_array, go through the combinations of
# plannings and selects appropriate solutions.

# rubocop:disable LineLength, MethodLength, ClassLength

class GoFindSolutionsV1Service
  def initialize(planning, calcul_solution_v1_instance, slotgroups_array)
    @planning = planning
    @calcul = calcul_solution_v1_instance
    @slotgroups_array = slotgroups_array
    @users = @planning.users
  end

  def perform
    # calculate pre-requisites to plannings iterating
    @nb_trees = determine_number_of_trees
    @nb_branches = determine_number_of_branches
    @nb_slotgroups = @slotgroups_array.count
    # go through plannings, select them, store them
    @test_possibilities = go_through_plannings
    { test_possibilities: @test_possibilities }
  end

  def determine_number_of_trees
    @slotgroups_array.find { |x| x.ranking_algo == 1 }.nb_combinations_available_users
  end

  def determine_number_of_branches
    nb_branches = 1
    @slotgroups_array.each do |slotgroup|
      unless slotgroup.take_into_calculation_nb_branches_account
      nb_branches *= slotgroup.nb_combinations_available_users
      end
    end
    return nb_branches
  end

  def go_through_plannings
    # @planning_possibility = [ {sg_id: 1, combi: [combination of users]} , etc. ]
    test_possibilities = []
    for tree in 1..@nb_trees
      for branch in 1..@nb_branches
        # re init
        @planning_possibility = []
        overlaps_best_scoring = nil
        for sg_ranking in 1..@nb_slotgroups # slotgroups rankings
          position = identify_position(tree, branch, sg_ranking)
          combination = identify_slotgroup_combination(position, sg_ranking)
          slotgroup_id = find_slotgroup_by_ranking(sg_ranking).id
          @planning_possibility << { sg_ranking: sg_ranking, sg_id: slotgroup_id , combination: combination, overlaps: nil }
        end
        test_possibilities << @planning_possibility
        # *** now we have @planning_possibility which contains a possibility of planning ***
        # evaluate overlapping users
        # J EN SUIS LA MAIS FAUT CHECKER LE DEBUT DU CODE AVANT D AVANCER TROP;
        # unless evaluate_overlaps_for_a_planning(@planning_possibility, overlaps_best_scoring)
        # only if better than our best, evaluate weekly hours respect
        # only if better than our best, store solution
        # end
      end
    end
    return test_possibilities
  end

private

  def identify_position(tree, branch, sg_ranking)
    # position = for each slotgroup, which one of the combinations of available
    # users are we at?
    # position = "itérateur_position" dans ma doc
    # interval_position = "numéro=_intervalle" dans ma doc
    position = 0 # init
    slotgroup = find_slotgroup_by_ranking(sg_ranking)
    if tree != 1 && sg_ranking == 1
      position = @nb_trees
    else
      if branch == 1 || sg_ranking == 1 || slotgroup.nb_combinations_available_users == 1 ||
      (slotgroup.nb_combinations_available_users == 1 && slotgroup.calculation_interval == 1)
      position = 1
      else
        # on calcule numéro_intervalle <=> interval_position puis
        # on calcule position <=> itérateur_position
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
    @slotgroups_array.find { |x| x.id == slotgroup_id }
  end

  def find_slotgroup_by_ranking(ranking)
    @slotgroups_array.find { |x| x.ranking_algo == ranking }
  end

  def identify_slotgroup_combination(position, sg_ranking)
    # we need the combination of users #position for this sg
    slotgroup = find_slotgroup_by_ranking(sg_ranking)
    combination = slotgroup.combinations_of_available_users[position - 1]
    # -1 because Arrays serialization starts at 0
  end

  def evaluate_overlaps_for_a_planning(planning, overlaps_best_scoring)
    overlaps = 0
    planning.each do |slotgroup_possibility| # slotgroup_possibility = { sg_id: 1, combination: [a,b] }
      # break if this is not an optimal solution in terms of overlaping users
      return false if overlaps_lower_than_best?(overlaps_slotgroup, overlaps_best_scoring)
      break if overlaps_lower_than_best?(overlaps_slotgroup, overlaps_best_scoring)
      # else, evaluate overlaps for this slotgroup possibility
      if evaluate_overlap_for_a_slotgroup_possibility(slotgroup_possibility).is_number?
        overlaps += evaluate_overlaps_for_a_slotgroup_possibility(slotgroup_possibility)
      else
      end
    end
  end

  def evaluate_overlaps_for_a_slotgroup_possibility(slotgroup_possibility)
    # does this slotgroup_possibility overlap another slotgroup?
    # => get intersection of overlapping users if any.
    slotgroup = find_slotgroup_by_id(slotgroup_possibility[:sg_id])
    slotgroup_combination = slotgroup_possibility[:combination]
    overlaps_slotgroup = 0
    slotgroup.overlaps.each do |overlapping_slotgroup_hash|
      overlapping_slotgroup_id = overlapping_slotgroups_array[:slotgroup_id]
      # on passe si le slotgroup overlappé n'est pas à simuler
      next if find_slotgroup_by_id(overlapping_slotgroup_id).simulation_status == false
      # on identifie l'intersection des users de ces 2 slotgroups
      intersect = find_slotgroup_by_id(overlapping_slotgroup_id).list_available_users & slotgroup.list_available_users
      # on passe à l'overlap suivant si pas d'intersection
      next if intersect.empty? || !intersect.count.positive?
      # si intersection, on ajoute à planning_possibility[:overlaps]
      overlapping_users_array << { sg_id: overlapping_slotgroup_id, users: intersect.flatten! }
      overlaps_slotgroup += intersect.flatten.count
    end
    # mettre en mémoire tous les overlaps pour cette planning_possibility
    planning_possibility[:overlaps] = overlapping_users_array.flatten!
    return overlaps_slotgroup
  end

  def find_slotgroup_possibility_by_id(planning_possibility, overlapping_slotgroup_id)
  end

  def overlaps_lower_than_best?(overlaps, overlaps_best_scoring)
    overlaps.positive? && overlaps >= overlaps_best_scoring
  end
end

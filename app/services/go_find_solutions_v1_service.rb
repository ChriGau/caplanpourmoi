# from slots_array and slotgroups_array, go through the combinations of
# plannings and selects appropriate solutions.

# rubocop:disable LineLength, MethodLength, AbcSize, ClassLength

class GoFindSolutionsV1Service
  attr_accessor :nb_trees, :nb_branches, :nb_slotgroups,
                :iteration_id, :solutions_array

  attr_reader :slotgroups_array

  require 'csv'

  def initialize(planning, slotgroups_array, compute_solution_instance)
    @slotgroups_array = slotgroups_array
    @planning = planning
    @compute_solution = compute_solution_instance
    @no_solution_user_id = determine_no_solution_user.id
    @employees_involved = @planning.users # Array of users
    # stocker plannings et solutions previous/next pour DRY - sert au grading
    @previous_planning = @planning.get_previous_week_planning
    @previous_planning_solution = @previous_planning.chosen_solution if !@previous_planning.nil?
    @next_planning = @planning.get_next_week_planning
    @next_planning_solution = @next_planning.chosen_solution if !@next_planning.nil?
    @duration_per_sg_array = determine_duration_per_sg_array # [ {:sg_id = 1 , length_sec = 1, :dates = [d1 (,d2)] }, {...} ]
    @total_duration_sg = determine_total_duration_sg # sum of previous (decimal, sec)
    @total_availabilities = determine_total_availabilities # useful for grading fitness
  end

  def perform
    # timestamps t4
    t = @compute_solution.timestamps_algo << ["t4", Time.now]
    @compute_solution.update(timestamps_algo: t)
    # calculate pre-requisites to plannings iterating
    self.nb_trees = determine_number_of_trees
    self.nb_branches = determine_number_of_branches
    self.nb_slotgroups = @slotgroups_array.count
    # iterate through planning possibilities to extract solutions
    build_solutions = go_through_plannings
    # select the best solutions
    # timestamps t5 - begin pick best solutions
    t = @compute_solution.timestamps_algo << ["t5", Time.now]
    @compute_solution.update(timestamps_algo: t)
    list_of_solutions = pick_best_solutions(build_solutions[:solutions_array], 20)
    # return
    [ build_solutions[:calculation_abstract], list_of_solutions ]
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
    nb_branches
  end

  # rubocop:disable For

  def go_through_plannings
    # planning_possibility = [ {sg_id: 1, combi: [combination of users_ids]} , {...} ]
    test_possibilities = []
    solution_id = 0
    self.solutions_array = []
    overlaps_best_scoring = init_overlaps_best_scoring
    nb_conflicts_best_scoring = init_overlaps_best_scoring
    possibility_id = 0
    iteration_id = 0
    nb_cuts_within_tree = 0
    next_tree = nil
    next_branch = nil
    # init for grading solutions
    best_grade = 0
    grade = 0

    # let's HIT THE TREE
    for tree in 1..nb_trees
      for branch in 1..nb_branches
        planning_possibility = []
        # next if solution_id ==  1000  # pour stopper les itérations au bout de la nième solution
        # we skip this branch if we must
        next if must_we_jump_to_another_branch?(tree, next_tree, branch, next_branch)
        # let's build a planning possibility
        for sg_ranking in 1..nb_slotgroups # slotgroups rankings
          position = identify_position(tree, branch, sg_ranking)
          combination = identify_slotgroup_combination(position, sg_ranking) # Array of user ids
          slotgroup_id = find_slotgroup_by_ranking(sg_ranking).id
          planning_possibility << {
                                    sg_ranking: sg_ranking,
                                    sg_id: slotgroup_id,
                                    combination: combination,
                                    overlaps: nil }
        end
        # *** now we have a planning_possibility which contains a possibility of planning ***
        possibility_id += 1
        # evaluate overlaps for a planning_possibility
        result_overlaps_check = evaluate_overlaps_for_a_planning(planning_possibility,
                                                                 overlaps_best_scoring)
        # fix_overlaps of this planning_possibility
        planning_possibility = fix_overlaps(planning_possibility,
                                            result_overlaps_check)
        # update overlaps
        evaluate_overlaps_for_a_planning(planning_possibility, overlaps_best_scoring)
        # evaluate nb conflicts for this planning
        result_conflicts_check = evaluate_nb_conflicts_for_a_planning_possibility(planning_possibility, nb_conflicts_best_scoring)
        if result_conflicts_check[:success]
          nb_conflicts_best_scoring = result_conflicts_check[:nb_conflicts]
          # TODO, evaluate weekly hours respect
          # store solution if doesnt already exist - storing of solution is leaner
          solution_id += 1
          solution = planning_possibility_leaner_version(planning_possibility)
          #  où planning_possibility = [:sg_id, :combination = [id1, id2,...] ]
          # on enlèvera les doublons de solutions + tard car sinon la ligne ci-dessous est très consommatrice

          # on note la solution
          grade = grade_solution(solution)
          # si note > best du moment, on stocke la solution

          solutions_array << solution if grade > best_grade

                               # {
                               # solution_id: solution_id,
                               # possibility_id: possibility_id,
                               # nb_overlaps: overlaps_best_scoring,
                               # planning_possibility: planning_possibility,
                               # nb_conflicts: nb_conflicts_best_scoring
                               # }
          # toutes les 1000 solutions, on enlève les doublons de solutions
          # (les doublons peuvent apparaître lorsque l'on résout les conflits)
          # preferer uniq plutôt que stocker solution # unless solutions_array.select{|x| x == solution}.count.positive?
          solutions_array.uniq! if solution_id % 1000 == 0
        else
          # cut off all similar possibilities
          next_knot_caracteristics = go_to_next_knot(tree, branch,
            result_conflicts_check[:sg_ranking_where_conflicts_evaluation_is_lower_than_best])
          next_tree = next_knot_caracteristics[:tree]
          next_branch = next_knot_caracteristics[:branch]
          nb_cuts_within_tree += 1
        end
        iteration_id += 1
        # n'afficher que toutes les 1000 iterations pour ne pas impacter la perf en affichage
        puts '...... iteration ' + iteration_id.to_s if iteration_id % 1000 == 0
        # Let's not store all the possibilities to make this LEANER
        # test_possibilities << planning_possibility
      end
    end
    # FOR TESTING --> storing the planning possibilities in a CSV
    store_planning_possibilities_to_csv(solutions_array) if Rails.env.test?
    calculation_abstract = determine_calculation_abstract(iteration_id, nb_cuts_within_tree)
    {
      # test_possibilities: test_possibilities,
      solutions_array: solutions_array,
      # best_solution: nil,
      calculation_abstract: calculation_abstract }
  end

  # rubocop:enable For

  def grade_solution(solution)
    # grade solution
      conflicts_percentage = grading_conflicts_percentage(solution)
      nb_users_six_consec_days_fail = grading_nb_users_six_consec_days_fail_and_nb_users_daily_hours_fail(solution)[:nb_users_six_consec_days]
      nb_users_daily_hours_fail = grading_nb_users_six_consec_days_fail_and_nb_users_daily_hours_fail(solution)[:nb_users_daily_hours_fail]
      fitness = grading_fitness(solution)
      binding.pry
      # compactness
      # rate
      conflicts_percentage
  end

  def grading_conflicts_percentage(solution)
    # decimal => nb seconds where conflicts / total hours slotgroups to simulate
    nb_seconds_conflicts = 0 #init
    nb_hours_conflicts = solution.each do |solution_slotgroup_hash|
      nb_conflicts = 0 # init
      nb_conflicts = solution_slotgroup_hash[:combination].count(@no_solution_user_id)
      if nb_conflicts.positive?
        nb_seconds_conflicts +=  a * @duration_per_sg_array.select{ |x| x[:sg_id] == solution_slotgroup_hash[:sg_id] }[:duration]
      end
    end
    nb_seconds_conflicts / @total_duration_sg
  end

  def grading_nb_users_six_consec_days_fail_and_nb_users_daily_hours_fail(solution)
    # => number of users who work more than 6 consecutive days
    timeframe = @planning.evaluate_timeframe_to_test_nb_users_six_consec_days_fail
    nb_users_six_consec_days = 0
    nb_users_daily_hours = 0
    @employees_involved.each do |user|
    array_of_consec_days = [] # init
      timeframe.first.each do |date|
        # evaluate whether user works today, and if so how many seconds
        # { works_today => true or false, nb_seconds => 1 }
        result = works_at_this_date?(user, date, solution)
        if result[:works_today]
          # evaluation du nb de seconds_on_duty_today + incr si > 8
          # TODO > prévoir la liste (user + date) des éléments en inconformité (lancer SSI solution choisie?)
          nb_users_daily_hours += 1 if result[:nb_seconds]/3600 > 8
          if date == timeframe.last # si on est à la dernière date et qu'il travaille
             nb_users_six_consec_days += 1 if array_of_consec_days.count > 6 && consecutive_days_intersect_planning_week?(array_of_consec_days, @planning)
          else # pas la derniere date et il travaille
            array_of_consec_days << date
          end
        else # ne travaille pas
          nb_users_six_consec_days += 1 if array_of_consec_days.count > 6 && consecutive_days_intersect_planning_week?(array_of_consec_days, @planning)
          array_of_consec_days = [] # re init
        end
      end
    end
    { nb_users_six_consec_days: nb_users_six_consec_days,
      nb_users_daily_hours: nb_users_daily_hours }
  end

  def grading_fitness(solution)
    # => % : (overtime + undertime)/hplanning
    # TODO : affiner le cas où over/under >> hplanning
      fitness =  calculate_over_under_time(solution) / (@total_duration_sg/3600)
      puts "over_under_time => #{calculate_over_under_time(solution)}"
      puts "total duration => #{@total_duration_sg/3600}"
      puts "total availabilities => #{@total_availabilities}"
      puts "fitness => #{fitness}"
      puts "deviation => #{@total_availabilities / (@total_duration_sg/3600)}"

    # get fitness score
    if @total_duration_sg > @total_availabilities
      get_grading_fitness_score(fitness, @total_availabilities / (@total_duration_sg/3600))
    else
      get_grading_fitness_score(fitness)
    end
  end

  def grading_compactness

  end

  def pick_best_solutions(solutions_array, how_many_solutions_do_we_store)
    # Selects X solutions from a collection of solutions.
    # several solutions with 0 conflicts? => pick the last X ones
    # else, we pick the last X ones
    collection_no_conflicts = collect_solutions_with_no_conflicts(solutions_array)
    if collection_no_conflicts.count.positive?
      # if more optimal solutions than size of our top => pick the last size_selection_solutions ones
      if collection_no_conflicts.count >= how_many_solutions_do_we_store
        return collection_no_conflicts.last(how_many_solutions_do_we_store)
      else
        # pick the 1..how_many_solutions_do_we_store ones
        return collection_no_conflicts
      end
    else # if no optimal solutions
      # TODO => classer solutions par ordre croissant de conflicts
      # solutions_array.sort_by!{ |x| x[:nb_conflicts] }
      # if more solutions than size of our top
      if solutions_array.count >= how_many_solutions_do_we_store
        # select the last X ones qui ont le moins de conflicts
        return solutions_array.last(how_many_solutions_do_we_store)
      else # less than 'size_selection_solutions' partial solutions
        # select as many solutions as there are
        return solutions_array
      end
    end
  end

  # rubocop:enable GuardClause

  def determine_duration_per_sg_array
    # => [ {:sg_id, :duration in sec, :dates = [d1 (,d2)] } , {...} ]
    # get duration of each slotgroup
    # is then used to grade the solutions
    result = []
    slotgroups_array.each do |sg_hash|
      # mettre les dates auxquelles appartient le slotgroup pour pouvoir estimer ensuite le six_consec_days_fail
      if sg_hash.start_at.to_date != sg_hash.end_at.to_date
        dates = [ sg_hash.start_at.to_date, sg_hash.end_at.to_date]
      else
        dates = [sg_hash.start_at.to_date]
      end
      result << { sg_id: sg_hash.id,
                  duration: (sg_hash.end_at - sg_hash.start_at),
                  dates: dates }
    end
    result
  end

  def determine_total_duration_sg
    # length (sec) of all slotgroups
    # = la durée de tous les slots du planning, car sg_array peut <> planning si certains sont sans solution d'entrée
    @planning.slots_total_duration * 3600
  end

  def determine_calculation_abstract(iteration_id, nb_cuts_within_tree)
    { nb_solutions: calculate_nb_solutions,
      nb_optimal_solutions: calculate_nb_optimal_solutions,
      nb_iterations: iteration_id,
      nb_possibilities_theory: nb_trees * nb_branches,
      nb_cuts_within_tree: nb_cuts_within_tree,
    }
  end

  def determine_total_availabilities
    # => working hours of each employee - hard constraints if they have any
    # opening hours = 9-20 by default but we need to implement it as a manager's parameter
    result = 0
    @employees_involved.each do |employee|
      availability_user_hours = 11 * @planning.number_of_days
      @planning.list_of_days.each do |date|
        duration = 0
        start_timeframe = DateTime.new(date.year, date.month, date.day, 9)
        end_timeframe = DateTime.new(date.year, date.month, date.day, 20)
        employee.constraints.where('start_at <= ? and end_at >= ? and category != ?',
        end_timeframe, start_timeframe, Constraint.categories['preference']).each do |constraint|
          duration = constraint_duration_according_to_timeframe(constraint, 9, 20)
          availability_user_hours -= duration
        end
      end
    result += availability_user_hours
    end
    result
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

  def planning_possibility_leaner_version(planning_possibility)
    # [ {:sg_ranking, :sg_id, :combination, :overlaps}, {...} ] => [ {:sg_id, :combination}, {...} ]
    planning_possibility.each do |sg_hash|
      sg_hash.delete(:sg_ranking)
      sg_hash.delete(:overlaps)
    end
    return planning_possibility
  end

  private

  def get_grading_fitness_score(fitness, deviation = 0)
    case fitness
      when 0..deviation + 0.02
        3
      when  deviation + 0.02..deviation + 0.04
        2
      when  deviation + 0.04..deviation + 0.06
        1
      else
        0
    end
  end

  def calculate_over_under_time(solution)
    # evaluate (over/undertime for each user)
    total = 0
    @employees_involved.each do |employee|
      # get number of seconds worked
      seconds_worked = 0
      solution.each do |solution_hash|
        if solution_hash[:combination].include?(employee)
          seconds_worked += get_sg_duration_from_sg_id(solution_hash[:sg_id])
        end
      end
      total += (employee.working_hours - seconds_worked/3600).abs
    end
    total
  end

  def init_overlaps_best_scoring
    # max of overlaps = all users are in overlap for all sg
    @planning.users.count * nb_slotgroups
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
    @slotgroups_array.find { |x| x.id == slotgroup_id }
  end

  def find_slotgroup_by_ranking(ranking)
    @slotgroups_array.find { |x| x.ranking_algo == ranking }
  end

  def identify_slotgroup_combination(position, sg_ranking)
    # we need the combination of users #position for this sg
    @compute_solution.calcul_solution_v1.slotgroups_array.find{ |x| x.ranking_algo == sg_ranking }.combinations_of_available_users[position - 1].clone
  end

  def evaluate_overlaps_for_a_planning(planning, overlaps_best_scoring)
    # returns true if better than overlaps_best_scoring + scoring (=nb of overlaps)
    success = false
    overlaps = 0
    sg_ranking_where_overlap_evaluation_is_lower_than_best = nil
    planning.each do |slotgroup_possibility|
      # result = { :nb_overlaps_slotgroup, :slotgroup_possibility }
      result = evaluate_overlaps_for_a_slotgroup_possibility(slotgroup_possibility, planning)
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

  def evaluate_overlaps_for_a_slotgroup_possibility(slotgroup_possibility, planning_possibility)
    # does this slotgroup_possibility overlap other slotgroups? are there
    # any users working simultaneously on those slotgroups?
    slotgroup = find_slotgroup_by_id(slotgroup_possibility[:sg_id])
    slotgroup_possibility_combination = slotgroup_possibility[:combination] # [user_id1, user_id2,...]
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
      next if find_slotgroup_possibility_by_id(overlapped_slotgroup_id, planning_possibility).nil?
      overlapped_slotgroup_possibility = find_slotgroup_possibility_by_id(overlapped_slotgroup_id, planning_possibility)
      users_in_overlap = slotgroup_possibility_combination & overlapped_slotgroup_possibility[:combination] # => Array of users in overlap's ids
      unless users_in_overlap.nil? || users_in_overlap.empty?
        nb_overlaps_slotgroup += users_in_overlap.flatten.count
        slotgroup_possibility_overlaps_array << { sg_id: overlapped_slotgroup_id, users: users_in_overlap.flatten }
      end
    end
    # update slotgroup_possibility[:overlaps]
    slotgroup_possibility[:overlaps] = slotgroup_possibility_overlaps_array
    { nb_overlaps_slotgroup: nb_overlaps_slotgroup, slotgroup_possibility: slotgroup_possibility }
  end

  def find_slotgroup_possibility_by_id(slotgroup_id, planning_possibility)
    planning_possibility.find { |x| x[:sg_id] == slotgroup_id }
  end

  def overlaps_equal_zero_or_lower_than_best?(overlaps, overlaps_best_scoring)
    # if true => success
    overlaps.zero? || overlaps <= overlaps_best_scoring
  end

  def collect_solutions_with_no_conflicts(solutions_array)
    solutions_array.select { |x| calculate_nb_conflicts(x).zero? }
  end

  def calculate_nb_conflicts_for_a_solution(solution_array)
    solution_array[:combination].select{ |c| c == determine_no_solution_user.id }.count
  end

  def calculate_nb_solutions
    solutions_array.count
  end

  def calculate_nb_optimal_solutions
    # count nb of solutions with no conflicts
    # TODO, update this method when weekly hours check will be set up
    solutions_array.select { |x| calculate_nb_conflicts(x).zero? }.count
  end

  def calculate_nb_conflicts(solution_array)
    # => nombre de conflicts pour 1 solution
    solution_array.map{ |x| x[:combination] }.flatten.count(determine_no_solution_user.id)
  end

  def calculate_nb_possibilities_below_this_knot(sg_ranking)
    nb_possibilities = 1
    @slotgroups_array.each do |slotgroup|
      if slotgroup.ranking_algo > sg_ranking && (slotgroup.simulation_status == true)
        nb_possibilities *= slotgroup.nb_combinations_available_users
      end
    end
    nb_possibilities
  end

  def determine_no_solution_user
    User.find_by(first_name: 'no solution')
  end

  def fix_overlaps(planning_possibility, result_overlaps_check)
    # régler les pbs d'overlap pour une planning_possibility
    # s'il existe >0 overlaps
    unless result_overlaps_check[:nb_overlaps_of_a_planning].zero?
      # TODO : order @compute_solution.overlaps par ordre de slotgroup du + au - prioritaire
      @compute_solution.calcul_solution_v1.slotgroups_array.each do |slotgroup|
        slotgroup.overlaps.each do |overlaps| # overlaps => [ {}, {},... ]
          # mettre les users du sg overlappé en overlap à no solution
          # binding.pry
          users_overlapped_sg = planning_possibility.select{ |h| h[:sg_id] == overlaps[:slotgroup_id] }.first[:combination] # => Array of users'ids
          users_initial_sg = planning_possibility.select{ |h| h[:sg_id] == slotgroup.id }.first[:combination]
          users_overlapped_sg.each do |user_id|
            if users_initial_sg.include?(user_id) # ce user est en overlap
              planning_possibility_hash = planning_possibility.select{ |h| h[:sg_id] == overlaps[:slotgroup_id] }.first
              # get index of user in overlapped sg combination
              index_user_to_replace = planning_possibility_hash[:combination].index(user_id)
              replace_user_in_planning_possibility_hash(planning_possibility_hash, index_user_to_replace)
              evaluate_overlaps_for_a_planning(planning_possibility, 0)
            end
          end
        end
      end
    end
    evaluate_overlaps_for_a_planning(planning_possibility, 0)
    return planning_possibility
  end

  def replace_user_in_planning_possibility_hash(planning_possibility_hash, index_of_user_to_replace)
    planning_possibility_hash[:combination][index_of_user_to_replace] = determine_no_solution_user.id
    # script bis = .delete_at(pos) puis planning_possibility_hash[:combination] << determine_no_solution_user.id
  end

  def evaluate_nb_conflicts_for_a_planning_possibility(planning_possibility, nb_conflicts_best_scoring)
    # => nb of users = no solution
    nb_conflicts = 0
    success = true
    sg_ranking = nil
    planning_possibility.each do |poss_hash|
      nb_conflicts += poss_hash[:combination].select{ |u| u == determine_no_solution_user.id }.count
      if nb_conflicts > nb_conflicts_best_scoring
        success = false
        sg_ranking = poss_hash[:sg_ranking]
        break
      end
    end
    return { success: success,
             nb_conflicts: nb_conflicts,
             sg_ranking_where_conflicts_evaluation_is_lower_than_best: sg_ranking }
  end

  def store_planning_possibilities_to_csv(solutions_array)
    csv_options = { col_sep: ',', force_quotes: true, quote_char: '"' }
    time = Time.now
    filepath    = 'algo_test' + time.day.to_s + "-" + time.month.to_s + "-" +time.hour.to_s+"h "+ time.min.to_s+ '.csv'

    CSV.open(filepath, 'wb', csv_options) do |csv|
      csv << ['solution_id']
      solutions_array.each do |solutions_array_hash|
        csv << [solutions_array_hash[:solution_id].to_s]
        csv << ['', 'sg_ranking', 'sg_id', 'combination', 'overlaps']
        solutions_array_hash[:planning_possibility].each do |planning_possibility_hash|
        combination = ""
        planning_possibility_hash[:combination].each do |user|
          combination += user.first_name + ', '
        end
        csv << [ '',
                planning_possibility_hash[:sg_ranking].to_s,
                planning_possibility_hash[:sg_id].to_s,
                combination,
                planning_possibility_hash[:overlaps] ]
        end
        csv << ['------------------------------------------------']
      end
    end
  end

  def get_planning_related_to_a_date(date)
    Planning.find_by(year: date.year, week_number: date.cweek)
  end

  def works_at_this_date?(user, date, solution)
    # true if user is working. 2 cas : date >> planning qui a 1 chosen solution
    # ou date = solution generee via go_through_plannings mais non saved
    solution_to_take_into_account = solution_to_take_into_account(date)
    if !solution_to_take_into_account.nil? # si on est sur le previous ou next planning
      works_today_binary = user.works_today?(date, solution_to_take_into_acount)
    else
      works_today_binary = works_today?(user, date, solution)
    end
  end

  def solution_to_take_into_account(date)
    if get_planning_related_to_a_date(date) == @previous_planning
      @previous_planning_solution
    elsif get_planning_related_to_a_date(date) == @next_planning
      @next_planning_solution
    else
      nil
    end
  end

  def works_today?(user, date, solution)
    # => { :result => true true if in solution generated via go_through_planning, user works on date,
    # :nb_seconds => nb of seconds worked on this date }
    #
    # solution = [ {:sg_id = 1, :combination = [] }, {...} ]
    list_of_sg_ids = []
    list_of_combinations = []
    # choper les id des slotgroups de cette date
    a = @duration_per_sg_array.select{ |x| x[:dates].include?(date) }
    a.each do |sg_hash|
      list_of_sg_ids << sg_hash.fetch_values(:sg_id)
    end
    list_of_sg_ids.flatten
    # récupérer les combinations correspondantes
    sg_solution = solution.select{ |y| list_of_sg_ids.include?(y[:sg_id]) }
    sg_solution.each do |solution_hash|
      list_of_combinations << solution_hash.fetch_values(:combination)
    end
    list_of_combinations.flatten.uniq!
    # user est dans combination?
    if list_of_combinations.include?(user)
      # si oui, on retourne true + son nombre de seconds travaillées
      nb_seconds = 0
      list_of_sg_ids.each do |sg_id|
        nb_seconds += @duration_per_sg_array.select{ |x| x[:sg_id] == sg_id}[:length_sec]
      end
      @duration_per_sg_array.select{ |x| x[:sg_id] == sg_id}
      { works_today: true,
        nb_seconds:  nb_seconds
      }
    else
      { works_today: false,
        nb_seconds: 0 }
    end
  end

  def consecutive_days_intersect_planning_week?(array_of_consec_days, planning)
    start_time = get_first_date_of_a_week(planning.year, planning.week_number)
    array_of_consec_days & [start_time .. start_time + 6].count.positive?
  end

  def get_sg_duration_from_sg_id(sg_id)
    @duration_per_sg_array.select{ |x| x[:sg_id] == sg_id}[length_sec]
  end

end

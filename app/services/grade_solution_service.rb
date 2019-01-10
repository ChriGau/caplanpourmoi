# grades a solution which has not yet been saved
# triggered during GoThroughPlanning

# rubocop:disable LineLength, MethodLength, ClassLength

class GradeSolutionService
  attr_accessor :slots_array, :planning, :users, :calcul, :slotgroups_array

  def initialize(solution, total_duration_sg, no_solution_user_id, duration_per_sg_array, planning, total_availabilities, employees_involved)
    @solution = solution
    @total_duration_sg = total_duration_sg
    @no_solution_user_id = no_solution_user_id
    @duration_per_sg_array = duration_per_sg_array
    @planning = planning
    @total_availabilities = total_availabilities
    @employees_involved = employees_involved
  end

  # rubocop:disable AbcSize

  def perform
      # conflicts_percentage => %
      conflicts_percentage = grading_conflicts_percentage
      # puts "conflicts_percentage = #{conflicts_percentage}"
      # decimal => nb seconds where conflicts / total hours slotgroups to simulate
      nb_users_six_consec_days_fail = grading_nb_users_six_consec_days_fail_and_nb_users_daily_hours_fail[:nb_users_six_consec_days]
      # puts "number of users = #{nb_users_six_consec_days_fail}"
      # number of users
      nb_users_daily_hours_fail = grading_nb_users_six_consec_days_fail_and_nb_users_daily_hours_fail[:nb_users_daily_hours_fail]
      # puts "nb_users_daily_hours_fail = #{nb_users_daily_hours_fail}"
      # grade
      fitness = grading_fitness
      # puts "fitness = #{fitness}"
      # nb of users
      users_non_compact_solution = grading_compactness(grading_nb_users_six_consec_days_fail_and_nb_users_daily_hours_fail[:nb_days_worked_per_users])
      # puts "users_non_compact_solution = #{users_non_compact_solution}"
      # final grade (/100)
      grade = get_final_grade(conflicts_percentage, nb_users_six_consec_days_fail, nb_users_daily_hours_fail, fitness, users_non_compact_solution)
      # puts "grade  GO THROUGH PLANNINGS = #{grade}"
      grade
  end

private

  def grading_conflicts_percentage
    # decimal => nb seconds where conflicts / total hours slotgroups to simulate
    nb_seconds_conflicts = 0 #init
    nb_hours_conflicts = @solution.each do |solution_slotgroup_hash|
      nb_conflicts = 0 # init
      nb_conflicts = solution_slotgroup_hash[:combination].count(@no_solution_user_id)
      if nb_conflicts.positive?
        nb_seconds_conflicts +=  nb_conflicts * @duration_per_sg_array.select{ |x| x[:sg_id] == solution_slotgroup_hash[:sg_id] }.first[:duration]
      end
    end
    nb_seconds_conflicts / @total_duration_sg
  end

  def grading_nb_users_six_consec_days_fail_and_nb_users_daily_hours_fail
    # => number of users who work more than 6 consecutive days
    timeframe = @planning.evaluate_timeframe_to_test_nb_users_six_consec_days_fail
    nb_users_six_consec_days = 0
    nb_users_daily_hours = 0
    nb_days_worked_per_users = []
    @employees_involved.each do |user|
      # initialize hash per user containing the number of days worked
      # used later in the calculation of compactness
      nb_days_worked_per_users << { user: user.id, nb_days_worked: 0 }
      array_of_consec_days = [] # init
      timeframe.first.each do |date|
        # evaluate whether user works today, and if so how many seconds
        # { works_today => true or false, nb_seconds => 1 }
        result = works_at_this_date?(user, date, @solution)
        if result[:works_today]
          nb_days_worked_per_users.select{ |x| x[:user] == user.id }.first[:nb_days_worked] += 1
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
      nb_users_daily_hours_fail: nb_users_daily_hours,
      nb_days_worked_per_users: nb_days_worked_per_users }
  end

  def grading_fitness
    # => % : (overtime + undertime)/hplanning
    # TODO : affiner le cas où over/under >> hplanning
      fitness =  calculate_over_under_time / (@total_duration_sg/3600)
    # get fitness score
    if @total_duration_sg > @total_availabilities
      get_grading_fitness_score(fitness, (@total_availabilities / (@total_duration_sg/3600))*100)
    else
      get_grading_fitness_score(fitness)
    end
  end

  def calculate_over_under_time
    # evaluate (over/undertime for each user)
    total = 0
    @employees_involved.each do |employee|
      # get number of seconds worked
      seconds_worked = 0
      @solution.each do |solution_hash|
        if solution_hash[:combination].include?(employee.id)
          seconds_worked += get_sg_duration_from_sg_id(solution_hash[:sg_id])
        end
      end
      if seconds_worked/3600 > employee.working_hours
        total += seconds_worked/3600 - employee.working_hours
      else
        total += employee.working_hours - seconds_worked/3600
      end
    end
    total
  end

  def get_sg_duration_from_sg_id(sg_id)
    @duration_per_sg_array.select{ |x| x[:sg_id] == sg_id}.first[:duration]
  end

  def get_grading_fitness_score(fitness, deviation = 0)
    # toutes les solutions auront la meme deviation donc pas besoin de la prendre en compte
    fitness * 10
  end

  def grading_compactness(nb_days_worked_per_users)
    # nb_days_worked_per_users = [ {user: User, nb_days_worked: 1}, {...} ]
    workers = get_list_of_workers_for_a_solution # [user id1, ...]
    nb_users = 0 # init
    workers.each do |worker_id|
      next if worker_id == @no_solution_user_id
      days_real = nb_days_worked_per_users.select{ |x| x[:user] == worker_id }.first[:nb_days_worked]
      nb_users +=1 if  days_real > (User.find(worker_id).working_hours / 8).round
    end
    nb_users
  end

  def get_final_grade(conflicts_percentage, nb_users_six_consec_days_fail, nb_users_daily_hours_fail, fitness, compactness)
    # transforme les valeurs des critères en points selon le bareme défini
    # fitness is already a score
    # puts "conflicts = #{score_conflicts_percentage(conflicts_percentage) }"
    # puts "6 days = #{score_nb_users_six_consec_days_fail(nb_users_six_consec_days_fail)}"
    # puts "daily hours = #{score_nb_users_daily_hours_fail(nb_users_daily_hours_fail)}"
    # puts "fitness = #{fitness}"
    # puts "compactness = #{score_compactness(compactness)}"
    # puts "--------------------"
    sum = (score_conflicts_percentage(conflicts_percentage).to_f +
    score_nb_users_six_consec_days_fail(nb_users_six_consec_days_fail).to_f +
    score_nb_users_daily_hours_fail(nb_users_daily_hours_fail).to_f +
    fitness.to_f + score_compactness(compactness).to_f)
    sum / 42 * 100
  end

  def works_today?(user, date, solution)
    # => { :result => true if in solution generated via go_through_planning, user works on date,
    # :nb_seconds => nb of seconds worked on this date }
    # solution = [ {:sg_id = 1, :combination = [] }, {...} ]
    list_of_sg_ids = []
    list_of_combinations = []
    list_slotgroups = []
    # choper les id des slotgroups de cette date
    a = @duration_per_sg_array.select{ |x| x[:dates].include?(date) }
    a.each do |sg_hash|
      list_of_sg_ids << sg_hash.fetch_values(:sg_id)
    end
    list_of_sg_ids.flatten!
    # récupérer les ids des slotgroups dans lesquels le user bosse
    sg_solution = solution.select{ |y| list_of_sg_ids.include?(y[:sg_id]) }
    sg_solution.each do |solution_hash|
      # quand on vérifie sur une solution non saved, on a accès à un user_id, pas un User
      if solution_hash[:combination].include?(user) or solution_hash[:combination].include?(user.id) then
        list_slotgroups << solution_hash[:sg_id]
      end
    end
    # user est dans au moins 1 combination?
    if list_slotgroups.count.positive?
      # si oui, on retourne true + son nombre de seconds travaillées
      nb_seconds = 0
      list_slotgroups.each do |sg_id|
        nb_seconds += @duration_per_sg_array.select{ |x| x[:sg_id] == sg_id}.first[:duration]
      end
      { works_today: true,
        nb_seconds:  nb_seconds
      }
    else
      { works_today: false,
        nb_seconds: 0 }
    end
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

  def get_list_of_workers_for_a_solution
    # [ user id1, user id2,...]
    list = []
    @solution.each do |solution_hash|
      list << solution_hash[:combination]
    end
    list.flatten!
    list.uniq! if list.count > 1
    list
  end

  def get_planning_related_to_a_date(date)
    Planning.find_by(year: date.year, week_number: date.cweek)
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

  def score_conflicts_percentage(conflicts_percentage)
    # turn conflicts_percentage value into a grade
    conflicts_percentage.zero? ? 10 : (1 - conflicts_percentage) * 10
  end

  def score_nb_users_six_consec_days_fail(nb_users_six_consec_days_fail)
    nb_users_six_consec_days_fail.zero? ? 10 : (nb_users_six_consec_days_fail / @employees_involved.count)*10
  end

  def score_nb_users_daily_hours_fail(nb_users_daily_hours_fail)
    nb_users_daily_hours_fail.zero? ? 10 : (nb_users_daily_hours_fail / (@employees_involved.count * @planning.number_of_days ))*10
  end

  def score_compactness(users_non_compact_solution)
    case users_non_compact_solution
      when 0
        2
      when 1
        1
      else
        0
    end
  end

  def consecutive_days_intersect_planning_week?(array_of_consec_days, planning)
    start_time = get_first_date_of_a_week(planning.year, planning.week_number)
    array_of_consec_days & [start_time .. start_time + 6].count.positive?
  end
end

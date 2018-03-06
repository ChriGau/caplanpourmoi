class Slotgroup
  include ActiveModel::Validations # using ActiveModel to enable features
  include ActiveModel::Serialization

  attr_accessor :id, :start_at, :end_at, :role_id, :role_name, :planning_id,
                :nb_required, :nb_available, :list_available_users,
                :simulation_status, :slots_to_simulate, :overlaps,
                :combinations_of_available_users,
                :nb_combinations_available_users, :priority, :ranking_algo,
                :calculation_interval, :users_solution

  def initialize(id, slot_instance)
    @id = id
    @start_at = slot_instance.start_at
    @end_at = slot_instance.end_at
    @role_id = slot_instance.role_id
    @role_name = Role.find(slot_instance.role_id).name
    @planning_id = slot_instance.planning_id
    @priority = 1 # rand (5) faked for now
  end

  # rubocop:disable LineLength

  def determine_slotgroup_nb_required(slotgroup_id, slots_array)
    self.nb_required = slots_array.select { |x| x[:slotgroup_id] == slotgroup_id }.count
  end

  def determine_slotgroup_availability(user_instances)
    # sets nb available users + lists them
    nb_available_users = 0
    array_available_users = []
    user_instances.each do |user|
      if user.skilled_and_available?(start_at, end_at, role_id)
        nb_available_users += 1
        array_available_users << user
      end
    end
    self.nb_available = nb_available_users
    self.list_available_users = array_available_users
  end

  def determine_slotgroup_simulation_status
    return self.simulation_status = true if nb_available.positive?
    return self.simulation_status = false unless nb_available.positive?
  end

  def determine_nb_slots_to_simulate
    nb_available >= nb_required ? nb_required : nb_available
  end

  def make_user_unavailable(overlapping_user)
    # make unavailable in overlapped slotgroup
    make_user_actually_unavailable(overlapping_user) if list_available_users.include?(overlapping_user)
  end

  def make_user_actually_unavailable(overlapping_user)
    list_available_users.delete(overlapping_user)
    self.nb_available -= 1 if nb_available != 0
  end

  def more_or_equal_available_as_required?
    nb_available >= nb_required
  end

  def take_into_calculation_interval_account(slotgroup_bis)
    slotgroup_bis.ranking_algo < ranking_algo ||
      slotgroup_bis.ranking_algo == ranking_algo ||
      slotgroup_bis.simulation_status == false
  end

  def take_into_calculation_nb_branches_account
    ranking_algo == 1
  end

  # rubocop:disable AbcSize, IfInsideElse, ConditionalAssignment, MethodLength
  # IfInsideElse <, ConditionalAssignment => disabled bcz makes method reading less fluid

  def calculate_interval_position(branch, true_or_false)
    interval = calculation_interval
    if true_or_false == true
      if (branch % nb_combinations_available_users).zero?
        interval_position = branch / nb_combinations_available_users
      else
        interval_position = (branch / nb_combinations_available_users).abs + 1
      end
    else
      if (branch % interval).zero?
        interval_position = (branch / interval).abs
      else
        interval_position = (branch / interval).abs + 1
      end
    end
    interval_position
  end
  # rubocop:enable AbcSize
  # rubocop:disable BlockNesting, For, AbcSize,PerceivedComplexity, CyclomaticComplexity

  def calculate_position(branch, interval_position, true_or_false)
    if true_or_false == true
      if branch <= nb_combinations_available_users
        position = branch
      elsif (interval_position * nb_combinations_available_users - branch).zero?
        position = nb_combinations_available_users
      else
        position = nb_combinations_available_users - ((interval_position * nb_combinations_available_users) - branch).abs
      end
    else
      if branch <= calculation_interval
        position = 1
      elsif (interval_position % nb_combinations_available_users).zero?
        position = nb_combinations_available_users
      elsif interval_position < nb_combinations_available_users
        position = interval_position
      else
        for a in 1..calculation_interval
          if ((interval_position + a) % nb_combinations_available_users).zero?
            position = nb_combinations_available_users - a
            break
          end
        end
      end
    end
    position
  end
end

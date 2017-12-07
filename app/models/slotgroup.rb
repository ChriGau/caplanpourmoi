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
    @priority = rand(5) # faked for now
  end

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
    nb_available.positive? ? self.simulation_status = true : self.simulation_status = false
  end

  def determine_combinations_size
    nb_available >= nb_required ? nb_required : nb_available
  end

  def make_user_unavailable(overlapping_user)
    # make unavailable in overlapped slotgroup
    if list_available_users.include?(overlapping_user)
      list_available_users.delete(overlapping_user)
      self.nb_available -= 1 if nb_available != 0
    end
  end

  def take_into_calculation_interval_account(slotgroup_bis)
    slotgroup_bis.ranking_algo < ranking_algo || slotgroup_bis.ranking_algo == ranking_algo || slotgroup_bis.simulation_status == false
  end
end

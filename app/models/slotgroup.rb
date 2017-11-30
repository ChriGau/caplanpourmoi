class Slotgroup < ApplicationRecord
  has_many :slots

  def start_at
    # returns start date of the 1st slot related to this slotgroup
    slots.first.start_at
  end

  def end_at
    # returns end date of the  1st slot related to this slotgroup
    slots.first.end_at
  end

  def role_id
    # returns role_id of the  1st slot related to this slotgroup
    slots.first.role_id
  end

  def role_name
    # returns name of the role of the 1st slot related to a slotgroup
    slots.first.role_id.name
  end

  def solution_slots_user_id
    # TODO // cf table solutionslots
    # returns Array of the users of the solution slots related to this slotgroup
    slots.map(&:user_id)
  end

  def solution_slots_user_name
    # returns Array of the users names of 1st slot belonging to this slotgroup
    # TODO
    slots.map(&:user).map(&:concatenate_first_and_last_name)
  end

  def solution_slots_users
  end

  def planning_id
    # Returns planning_id of the slots related to this slotgroup
    slots.first.planning_id
  end

  def planning_name
    # Get name of the planning related to the 1st slot related to this slotgroup
    slots.first.name
  end

  def nb_required
    # returns number of slots relative to this slotgroup
    Slot.where(slotgroup_id: self.id).count
  end

  def list_available_skilled_users
    #returns list of skilled (have role) and available (no constraint) users
    list = []
    users = User.where.not(first_name: "no solution").includes(:roles, :plannings, :teams).sort
    users.each do |user|
      list << user if user.is_skilled_and_available?(self.start_at, self.end_at, self.role_id) == true
    end
    return list
  end

  def set_slotgroup_simulation_status
    #TODO - false if 0 available users, else true
  end

  def nb_available
    #TODO - count of list_available_skilled_users
    self.list_available_skilled_users.count
  end

  def overlapping_slotgroups(slotgroup_id)
    #TODO - return list of slotgroups overlapping this slotgroup
  end

  def overlapping_users(slotgroup_id)
    #TODO - return list of users simultaneously required on overlapping slotgroups
    # and constrained slotgroups (required=available)
  end

  def combinations_of_available_users(slotgroup_id)
    #TODO - returns list of combinations
    #example : [ [1,5,4] , [1,6,4] ] => 2 combinations of triplets possible
  end

  def set_nb_combinations
    #TODO - count of combinations_of_available_users
  end

  def set_priority
    #TODO - max of slots' priority
  end

  def set_ranking_algo
    #TODO - order by decreasing number of combinations per slotgroups
  end

  def set_interval
    #TODO
  end

end

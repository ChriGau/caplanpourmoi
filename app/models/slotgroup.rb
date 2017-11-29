class Slotgroup < ApplicationRecord
  has_many :slots

  #test branching
  # TODO : after_save :set...

  #  --------------------------    Slotgroups HELPERS

  def slots
    # returns Array of slots instances related to a slotgroup
    Slot.where(slotgroup_id: self.id).to_a
  end

  def start_at
    # returns start date of the slots related to this slotgroup
    Slot.where(slotgroup_id: self.id).first.start_at
  end

  def end_at
    # returns end date of the slots related to this slotgroup
    Slot.where(slotgroup_id: self.id).first.end_at
  end

  def role_id
    # returns role_id of the slots related to this slotgroup
    Slot.where(slotgroup_id: self.id).first.role_id
  end

  def role_name
    # returns name of the role of the 1st slot related to a slotgroup
    Role.find(Slot.where(slotgroup_id: self.id).first.role_id).name
  end


  def user_id
    # returns list (array) of the users of the slots related to this slotgroup
    @users_id=[]
    @slots = Slot.where(slotgroup_id: self.id).each do |slot|
      @users_id << slot.user_id
    end
    return @users_id
  end

  def user_name
    # Returns list (array) of the users first + last names of the slots related to this slotgroup
    @names=[]
    @users = Slot.where(slotgroup_id: self.id).each do |slot|
      @users = User.where(id: slot.user_id).each do |user|
        @names << user.first_name + " " + user.last_name
      end
    end
    return @names
  end

  def planning_id
    # Applies to a slotgroup - returns planning_id of the slots related to this slotgroup
    Slot.where(slotgroup_id: self.id).first.planning_id
  end

  def planning_name
    # Applies to a slotgroup - returns planning_id of the slots related to this slotgroup
    Planning.where(Slot.where(slotgroup_id: self.id).first.planning_id).name
  end

  #  --------------------------    End of HELPERS

  def nb_required
    # returns number of slots relative to this slotgroup
    Slot.where(slotgroup_id: self.id).count
  end

  def list_available_skilled_users(slotgroup_id)
    #TODO - return list of available (no constraints) and skilled users
  end

  def set_nb_available_users
    #TODO - count of list_available_skilled_users
  end

  def overlapping_slotgroups(slotgroup_id)
    #TODO - return list of slotgroups overlapping this slotgroup
  end

  def overlapping_users(slotgroup_id)
    #TODO - return list of users simultaneously required on overlapping slotgroups
    # and constrained slotgroups (required=available)
  end

  def set_simulation_status
    #TODO - false if 0 available users, else true
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

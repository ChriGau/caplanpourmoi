class Slotgroup < ApplicationRecord
  has_many :slots

  #test branching
  # TODO : after_save :set...

  def user_id
    # Applies to a slotgroup
    # Returns list (array) of the users of the slots related to this slotgroup
    @users_id=[]
    @slots = Slot.where(slotgroup_id: self.id).each do |slot|
      @users_id << slot.user_id
    end
    return @users_id
  end

  def users
    # Applies to a slotgroup
    # Returns list (array) of the users names of the slots related to this slotgroup
    @names=[]
    @users = Slot.where(slotgroup_id: self.id).each do |slot|
      @users = User.where(id: slot.user_id).each do |user|
        @names << user.first_name
      end
    end
    return @names
  end

  def nb_required
    # returns number of slots relative to this slotgroup
    Slot.where(slotgroup_id: self.id).count
  end

  def self.list_available_skilled_users(slotgroup_id)
    #TODO - return list of available (no constraints) and skilled users
  end

  def set_nb_available_users
    #TODO - count of list_available_skilled_users
  end

  def self.overlapping_slotgroups(slotgroup_id)
    #TODO - return list of slotgroups overlapping this slotgroup
  end

  def self.overlapping_users(slotgroup_id)
    #TODO - return list of users simultaneously required on overlapping slotgroups
    # and constrained slotgroups (required=available)
  end

  def set_simulation_status
    #TODO - false if 0 available users, else true
  end

  def self.combinations_of_available_users(slotgroup_id)
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

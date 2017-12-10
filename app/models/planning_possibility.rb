class PlanningPossibility
  include ActiveModel::Validations # using ActiveModel to enable features
  include ActiveModel::Serialization

  attr_accessor :possibility_id, :planning_possibility, :nb_overlapping_users,
                :nb_overlaps_details, :nb_hours_overtime

  def initialize(id, slot_instance)
    @id = id
    @start_at = slot_instance.start_at
    @end_at = slot_instance.end_at
    @role_id = slot_instance.role_id
    @role_name = Role.find(slot_instance.role_id).name
    @planning_id = slot_instance.planning_id
    @priority = rand(5) # faked for now
  end
end

    # {
    # :possibility_id => 1,
    # :nb_overlapping_users => 1,
    # :overlaps_details =>
    #   {
    #   :slotgroup_id_1 => 1,
    #   :slotgroup_id_2 => 2,
    #   :overlapping_user => user,
    #   },
    # :nb_hours_overtime => 25.5,
    # :solution =>
    #   {
    #   :slotgroup_id => 1,
    #   :users => [instances of users]
    #   }
    # }

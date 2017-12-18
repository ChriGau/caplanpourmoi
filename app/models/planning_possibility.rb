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

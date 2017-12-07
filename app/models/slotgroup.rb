class Slotgroup < ApplicationRecord
  def new(cpt_slotgroup, slot)
    id = cpt_slotgroup
    start_at = slot_instance[:start_at]
    end_at = slot_instance[:end_at]
    role_id = slot_instance[:role_id]
    role_name = Role.find(slot_instance[:role_id]).name
    nb_required = nil
    nb_available = nil
    list_available_users = nil,
    simulation_status = nil,
    slots_to_simulate = nil,
    overlaps = nil,
    combinations_of_available_users = nil,
    nb_combinations_available_users = nil,
    priority = rand(5), # faked for now
    ranking_algo = nil,
    calculation_interval = nil,
    users_solution = nil
  end
end

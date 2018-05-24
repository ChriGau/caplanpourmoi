# == Schema Information
#
# Table name: slots
#
#  id          :integer          not null, primary key
#  start_at    :datetime
#  end_at      :datetime
#  planning_id :integer
#  role_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_slots_on_planning_id  (planning_id)
#  index_slots_on_role_id      (role_id)
#
# Foreign Keys
#
#  fk_rails_...  (planning_id => plannings.id)
#  fk_rails_...  (role_id => roles.id)
#

class Slot < ApplicationRecord
  belongs_to :planning, optional: true
  belongs_to :role
  validates :role_id, presence: true
  after_save :set_status
  has_many :solution_slots, dependent: :destroy
  has_many :solutions, through: :solution_slots

  def self.slot_templates
    slot_templates = []
    Role.find_each do |role|
      slot_templates << Slot.new(role_id: role.id)
    end
    slot_templates
  end

  def chosen_solution
    solutions.find_by(effectivity: :chosen)
  end

  def initialize_slot_hash
    { slotgroup_id: nil,
      simulation_status: false,
      slot_instance: self }
  end

  def similar_slots
    Slot.where('planning_id = ? and start_at = ? and end_at = ? and role_id = ?',
               planning_id, start_at, end_at, role_id)
  end

  def get_solution_slot(solution)
    solution_slots.find_by(solution: solution)
  end

  def get_available_users
    # for a given slot, get list of alternative users
    # <=> available + posess role
    # list des pers. dispos + possèdent rôle
    list_available_users = []
    self.planning.users.each do |user|
      list_available_users << user if user.available?(slot.start_at, slot.end_at)
      available.each do |user|
        # pour chacun d'eux, vérifier s'ils ne sont pas assignés à des slots en overlap
        # récupérer la liste des slots qui sont en overlap avec notre slot en overlap
      end
    end
  end

  def get_infos_to_reaffect_slot
    # => get infos to display in modal-reassignment
    result = []
    users = planning.users
    users.each do |user|
      sub_result = {}
      status = nil #init
      # compute status
      if get_solution_slot(planning.chosen_solution).user_id == user.id
        status = "assigned"
      elsif user.available?(start_at, end_at) # <=> has no constraint
        status = user.is_on_duty?(planning, self) ? "on duty" : "available"
      else
        status = "not available" # <=> has constraints
      end
      skilled = user.skilled?(role_id)
      a = user.nb_hours_planning(planning, self) # compute nb of hours
      sub_result[user.id] = { status: status,
                              skilled: skilled,
                              nb_hours_day: a[:hours_day],
                              nb_hours_day_status: a[:hours_day_status],
                              nb_hours_planning: a[:hours_planning],
                              nb_hours_planning_status: a[:hours_planning_status] }
      result << sub_result
    end
    # tri ordre alphabétique du status (assigned < available < not available < on duty)
    result.sort_by!{ |h| h.values[0][:status] }
    return result
  end

  def overlap_other_slot?(other_slot)
    # true if 2 slots are overlaping one another
    # rq : fin de slot à 18h, début other slot à 18h = no overlap
    start_at < other_slot.end_at && end_at > other_slot.start_at
  end

  private

  def set_status
    planning&.chosen_solution&.not_chosen!
    planning&.set_status
  end

end

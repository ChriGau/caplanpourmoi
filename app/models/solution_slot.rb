# == Schema Information
#
# Table name: solution_slots
#
#  id             :integer          not null, primary key
#  nb_extra_hours :integer
#  status         :integer
#  user_id        :integer
#  slot_id        :integer
#  solution_id    :integer
#
# Indexes
#
#  index_solution_slots_on_slot_id      (slot_id)
#  index_solution_slots_on_solution_id  (solution_id)
#  index_solution_slots_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (slot_id => slots.id)
#  fk_rails_...  (solution_id => solutions.id)
#  fk_rails_...  (user_id => users.id)
#

class SolutionSlot < ApplicationRecord
  belongs_to :solution
  belongs_to :user
  has_many :roles, through: :roles
  belongs_to :slot
  validates :solution_id, :slot_id, :user_id, presence: true
  has_one :planning, through: :solution
  has_one :role, through: :slot
  delegate :start_at, to: :slot
  delegate :end_at, to: :slot

  after_update :update_solution_and_solution_slot_attributes

  def evaluate_overlaps_for_a_solution_slot
    nb_overlaps = 0
    overlaps_details = []
    solution.solution_slots.where('user_id != ?', no_solution_user_id).each do |solution_slot|
      next if self == solution_slot
      if slot_overlap_other_slot?(self.slot_id, solution_slot.slot_id) && self.user_id == solution_slot.user_id# slots in overlap?
          nb_overlaps += 1
          overlaps_details << { solution_slot: id,
                                solution_slot_overlapped: solution_slot.id,
                                user: user_id }
      end
    end
    return { nb_overlaps: nb_overlaps, overlaps_details: overlaps_details }
  end

  private

  def no_solution_user_id
    User.find_by(first_name: 'no solution').id
  end

  def slot_overlap_other_slot?(slotid1, slotid2)
    # true if 2 slots are overlaping one another
    # similar method used in Slot. If you modify one, modify the other
    Slot.find(slotid1).start_at < Slot.find(slotid2).end_at && Slot.find(slotid1).end_at > Slot.find(slotid2).start_at
  end

  def update_solution_and_solution_slot_attributes
    # update solution
    self.solution.total_over_time
    self.solution.evaluate_nb_conflicts
    self.solution.evaluate_nb_overlaps
    self.solution.evaluate_nb_users_six_consec_days_fail
    self.evaluate_nb_users_daily_hours_fail
    self.evaluate_nb_users_in_overtime
    self.evaluate_compactness
    # update solution_slot (no attributes to update for now)
    # update compute_solution (nb_optimal_solutions)
    self.solution.compute_solution.evaluate_nb_optimal_solutions
  end
end

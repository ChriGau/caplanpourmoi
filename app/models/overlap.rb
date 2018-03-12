# == Schema Information
#
# Table name: overlaps
#
#  id                           :integer          not null, primary key
#  slotgroup_id                 :integer
#  overlapped_slotgroup_id      :integer
#  combinations_available_users :text
#  compute_solution_id          :integer
#
# Indexes
#
#  index_overlaps_on_compute_solution_id  (compute_solution_id)
#
# Foreign Keys
#
#  fk_rails_...  (compute_solution_id => compute_solutions.id)
#

class Overlap < ApplicationRecord
  belongs_to :compute_solution
end

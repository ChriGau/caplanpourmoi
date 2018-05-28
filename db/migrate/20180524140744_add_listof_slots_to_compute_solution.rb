class AddListofSlotsToComputeSolution < ActiveRecord::Migration[5.0]
  def change
    add_column :compute_solutions, :p_list_of_slots_ids, :text
  end
end

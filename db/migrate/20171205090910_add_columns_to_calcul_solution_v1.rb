class AddColumnsToCalculSolutionV1 < ActiveRecord::Migration[5.0]
  def change
    add_column :calcul_solution_v1s, :slots_array, :text
    add_column :calcul_solution_v1s, :slotgroups_array, :text
    add_column :calcul_solution_v1s, :information, :text
  end
end

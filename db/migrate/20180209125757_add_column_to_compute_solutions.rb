class AddColumnToComputeSolutions < ActiveRecord::Migration[5.0]
  def change
    add_column :compute_solutions, :p_nb_slots, :integer
    add_column :compute_solutions, :p_nb_hours, :string
    add_column :compute_solutions, :p_nb_hours_roles, :text
  end
end

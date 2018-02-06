class AddColumnsToComputeSolutions < ActiveRecord::Migration[5.0]
  def change
    add_column :compute_solutions, :nb_solutions, :integer
    add_column :compute_solutions, :nb_optimal_solutions, :integer
    add_column :compute_solutions, :nb_iterations, :integer
    add_column :compute_solutions, :nb_possibilities_theory, :integer
    add_column :compute_solutions, :calculation_length, :decimal
    add_column :compute_solutions, :nb_cuts_within_tree, :integer
  end
end

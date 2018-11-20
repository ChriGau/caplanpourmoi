class AddColumnsToComputeSolutionsAgain < ActiveRecord::Migration[5.0]
  def change
    add_column :compute_solutions, :go_through_solutions_mean_time_per_slot, :float
    add_column :compute_solutions, :solution_storing_mean_time_per_slot, :float
    add_column :compute_solutions, :mean_time_per_slot, :float
    add_column :compute_solutions, :fail_level, :text
    add_column :compute_solutions, :percent_tree_covered, :float
  end
end

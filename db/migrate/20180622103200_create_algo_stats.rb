class CreateAlgoStats < ActiveRecord::Migration[5.0]
  def change
    create_table :algo_stats do |t|
      t.integer :nb_compute_solutions
      t.integer :nb_solutions
      t.integer :nb_fail
      t.float :go_through_solutions_mean_time_per_slot
      t.float :solutions_storing_mean_time
      t.float :tree_covered_mean
      t.float :total_mean_time
      t.timestamps
    end
  end
end

class AddTimestampsToComputeSolutions < ActiveRecord::Migration[5.0]
  def change
    add_column :compute_solutions, :timestamps_algo, :text
  end
end

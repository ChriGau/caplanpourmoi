class AddTimestampsToComputeSolutions < ActiveRecord::Migration[5.0]
  def change
    add_column :compute_solutions, :timestamps_algo, :text
    add_column :compute_solutions, :launching_source, :integer
  end
end

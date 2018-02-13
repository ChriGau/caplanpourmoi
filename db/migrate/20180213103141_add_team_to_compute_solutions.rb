class AddTeamToComputeSolutions < ActiveRecord::Migration[5.0]
  def change
    add_column :compute_solutions, :team, :text
  end
end

class AddNbConflictsToSolutions < ActiveRecord::Migration[5.0]
  def change
    add_column :solutions, :nb_conflicts, :integer
  end
end

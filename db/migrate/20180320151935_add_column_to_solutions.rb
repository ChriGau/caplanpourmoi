class AddColumnToSolutions < ActiveRecord::Migration[5.0]
  def change
    add_column :solutions, :nb_under_hours, :integer
  end
end

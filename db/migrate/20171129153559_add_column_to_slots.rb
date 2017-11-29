class AddColumnToSlots < ActiveRecord::Migration[5.0]
  def change
    add_column :slots, :simulation_status, :boolean
  end
end

class ChangeSimulationStatusColumnOfRoles < ActiveRecord::Migration[5.0]
  def change
    change_column :slots, :simulation_status, :boolean, :default => false
  end
end

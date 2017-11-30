class SetSlotgroupSimulationStatusToFalseByDefault < ActiveRecord::Migration[5.0]
  def change
    change_column :slotgroups, :simulation_status, :boolean, :default => false
  end
end

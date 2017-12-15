class DestroyTableSlotgroups < ActiveRecord::Migration[5.0]
  def change
    remove_column :slots, :slotgroup_id
    remove_column :slots, :simulation_status
    drop_table :slotgroups
  end
end

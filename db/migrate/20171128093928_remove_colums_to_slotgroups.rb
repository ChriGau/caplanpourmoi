class RemoveColumsToSlotgroups < ActiveRecord::Migration[5.0]
  def change
    remove_column :slotgroups, :role_id
    remove_column :slotgroups, :start
    remove_column :slotgroups, :end
  end
end

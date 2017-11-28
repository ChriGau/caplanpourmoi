class AddColumnToSlotgroups < ActiveRecord::Migration[5.0]
  def change
    add_column :slotgroups, :role_id, :integer
  end
end

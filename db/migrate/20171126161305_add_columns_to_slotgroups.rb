class AddColumnsToSlotgroups < ActiveRecord::Migration[5.0]
  def change
    add_column :slotgroups, :start, :datetime
    add_column :slotgroups, :end, :datetime
  end
end

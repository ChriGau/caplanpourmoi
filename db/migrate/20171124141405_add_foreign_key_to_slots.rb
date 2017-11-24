class AddForeignKeyToSlots < ActiveRecord::Migration[5.0]
  def change
    add_reference :slots, :slotgroup, foreign_key: true, index: true
  end
end

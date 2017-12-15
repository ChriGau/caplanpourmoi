class AddForeignKeyToRoles < ActiveRecord::Migration[5.0]
  def change
    add_reference :roles, :slotgroup, foreign_key: true, index: true
  end
end

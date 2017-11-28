class RemoveForeignKeyToRoles < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :roles, column: :slotgroup_id
  end
end

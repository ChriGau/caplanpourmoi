class RemoveColumnOnRoles < ActiveRecord::Migration[5.0]
  def change
    remove_column :roles, :slotgroup_id
  end
end

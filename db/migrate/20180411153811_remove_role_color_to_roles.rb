class RemoveRoleColorToRoles < ActiveRecord::Migration[5.0]
  def change
    remove_column :roles, :role_color
  end
end

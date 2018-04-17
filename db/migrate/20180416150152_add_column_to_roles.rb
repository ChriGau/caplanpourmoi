class AddColumnToRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :roles, :intermediate, :text
  end
end

class AddColorIdToRoles < ActiveRecord::Migration[5.0]
  def change
    add_reference :roles, :color, foreign_key: true, index: true
  end
end

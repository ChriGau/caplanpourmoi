class AddColumnsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :working_hours, :integer
    add_column :users, :is_owner, :boolean
  end
end

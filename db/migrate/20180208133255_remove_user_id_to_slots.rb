class RemoveUserIdToSlots < ActiveRecord::Migration[5.0]
  def change
    remove_column :slots, :user_id
  end
end

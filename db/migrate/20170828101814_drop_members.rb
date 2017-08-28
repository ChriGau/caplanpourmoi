class DropMembers < ActiveRecord::Migration[5.0]
  def change
    drop_table :members
  end
end

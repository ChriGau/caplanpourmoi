class CreateTableOverlaps < ActiveRecord::Migration[5.0]
  def change
    create_table :overlaps do |t|
      t.integer :slotgroup_id
      t.integer :overlapped_slotgroup_id
      t.text :combinations_available_users
      t.references :compute_solution, foreign_key: true
      t.timestamp
    end
  end
end

class CreateSlotgroups < ActiveRecord::Migration[5.0]
  def change
    create_table :slotgroups do |t|
      t.integer :nb_required
      t.integer :nb_available
      t.boolean :simulation_status
      t.integer :priority
      t.integer :nb_combinations
      t.integer :ranking_algo
      t.integer :interval

      t.timestamps
    end
  end
end

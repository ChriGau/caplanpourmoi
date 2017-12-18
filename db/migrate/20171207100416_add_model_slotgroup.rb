class AddModelSlotgroup < ActiveRecord::Migration[5.0]
  def change
    create_table :slotgroups do |t|
      t.datetime :start_at
      t.datetime :end_at
      t.integer :role_id
      t.string :role_name
      t.integer :nb_required
      t.integer :nb_available
      t.text :list_available_users
      t.boolean :simulation_status
      t.text :slots_to_simulate
      t.text :overlaps
      t.text :combinations_of_available_users
      t.integer :nb_combinations_available_users
      t.integer :priority
      t.integer :ranking_algo
      t.integer :calculation_interval
      t.text :users_solution
      t.timestamps
    end
  end
end

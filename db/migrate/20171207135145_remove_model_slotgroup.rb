class RemoveModelSlotgroup < ActiveRecord::Migration[5.0]
  def change
    remove_column :slotgroups, :start_at
    remove_column :slotgroups, :end_at
    remove_column :slotgroups, :role_id
    remove_column :slotgroups, :role_name
    remove_column :slotgroups, :nb_required
    remove_column :slotgroups, :nb_available
    remove_column :slotgroups, :list_available_users
    remove_column :slotgroups, :simulation_status
    remove_column :slotgroups, :slots_to_simulate
    remove_column :slotgroups, :overlaps
    remove_column :slotgroups, :combinations_of_available_users
    remove_column :slotgroups, :nb_combinations_available_users
    remove_column :slotgroups, :priority
    remove_column :slotgroups, :ranking_algo
    remove_column :slotgroups, :calculation_interval
    remove_column :slotgroups, :users_solution
    drop_table :slotgroups
  end
end

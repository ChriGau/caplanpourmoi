class DropTeams < ActiveRecord::Migration[5.0]
  def change
       drop_table :teams
  end
end

class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|
      t.string :name
      t.references :owner, index:true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end

class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|
      t.references :planning, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end

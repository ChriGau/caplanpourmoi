class CreateConstraints < ActiveRecord::Migration[5.0]
  def change
    create_table :constraints do |t|
      t.datetime :start_at
      t.datetime :end_at
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end

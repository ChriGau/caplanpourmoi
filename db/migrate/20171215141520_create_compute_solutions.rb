class CreateComputeSolutions < ActiveRecord::Migration[5.0]
  def change
    create_table :compute_solutions do |t|
      t.integer :status
      t.references :planning, foreign_key: true

      t.timestamps
    end
  end
end

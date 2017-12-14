class CreateTableSolutions < ActiveRecord::Migration[5.0]
  def change
    create_table :solutions do |t|
      t.integer :calculsolutionv1_id
      t.integer :nb_overlaps
      t.integer :nb_extra_hours
      t.integer :status
      t.references :planning, foreign_key: true
    end
  end
end

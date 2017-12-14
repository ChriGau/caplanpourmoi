class CreateTableSolutionsSlots < ActiveRecord::Migration[5.0]
  def change
    create_table :solution_slots do |t|
      t.integer :nb_extra_hours
      t.integer :status
      t.references :user, foreign_key: true
      t.references :slot, foreign_key: true
      t.references :solution, foreign_key: true
    end
  end
end

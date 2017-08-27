class CreatePlannings < ActiveRecord::Migration[5.0]
  def change
    create_table :plannings do |t|
      t.integer :week_number
      t.integer :year
      t.integer :status

      t.timestamps
    end
  end
end
